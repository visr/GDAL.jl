using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Example taken from
# https://github.com/JuliaIO/ImageMagick.jl/blob/master/deps/build.jl
dependencies = [
    "build_Zlib.v1.2.11.jl",
    "build_GEOS.v3.7.2.jl",
    "build_SQLite.v3.28.0.jl",
    "build_PROJ.v6.1.0.jl",
    "build_MbedTLS.v2.6.1.jl"
]

for elem in dependencies
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process
    m = Module(:__anon__)
    Core.include(m, (joinpath(@__DIR__, elem)))
end

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgdal"], :libgdal),
    LibraryProduct(prefix, ["libcurl"], :libcurl),
    ExecutableProduct(prefix, "gdal_contour", :gdal_contour_path),
    ExecutableProduct(prefix, "gdal_grid", :gdal_grid_path),
    ExecutableProduct(prefix, "gdal_rasterize", :gdal_rasterize_path),
    ExecutableProduct(prefix, "gdal_translate", :gdal_translate_path),
    ExecutableProduct(prefix, "gdaladdo", :gdaladdo_path),
    ExecutableProduct(prefix, "gdalbuildvrt", :gdalbuildvrt_path),
    ExecutableProduct(prefix, "gdaldem", :gdaldem_path),
    ExecutableProduct(prefix, "gdalinfo", :gdalinfo_path),
    ExecutableProduct(prefix, "gdallocationinfo", :gdallocationinfo_path),
    ExecutableProduct(prefix, "gdalmanage", :gdalmanage_path),
    ExecutableProduct(prefix, "gdalsrsinfo", :gdalsrsinfo_path),
    ExecutableProduct(prefix, "gdaltindex", :gdaltindex_path),
    ExecutableProduct(prefix, "gdaltransform", :gdaltransform_path),
    ExecutableProduct(prefix, "gdalwarp", :gdalwarp_path),
    ExecutableProduct(prefix, "nearblack", :nearblack_path),
    ExecutableProduct(prefix, "ogr2ogr", :ogr2ogr_path),
    ExecutableProduct(prefix, "ogrinfo", :ogrinfo_path),
    ExecutableProduct(prefix, "ogrlineref", :ogrlineref_path),
    ExecutableProduct(prefix, "ogrtindex", :ogrtindex_path),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaGeo/GDALBuilder/releases/download/v3.0.3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.2.aarch64-linux-gnu.tar.gz", "ccf0dbd0c31acd3a754f4e0b93b3d8ab7af088d8dfacbcbdcf7829edaecc5e1f"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/GDAL.v3.0.2.aarch64-linux-musl.tar.gz", "362d238cc7b97d948c3188416f71e92f728132cff77f31b5a199fd6b880439ca"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/GDAL.v3.0.2.arm-linux-gnueabihf.tar.gz", "6551460e414f74d00067e19a36fd7ae306678b55fa0c088af5eb05522193a8fa"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/GDAL.v3.0.2.arm-linux-musleabihf.tar.gz", "98d3e343ea2316d72ab84bda3ca532cbeacc795dcd89bd26e8f60620a30184f6"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.2.i686-linux-gnu.tar.gz", "fee85e2bddeb0199175791447473ad5ff7aed3905661baa0b6fdf3152fecf452"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/GDAL.v3.0.2.i686-linux-musl.tar.gz", "76ed20142a50b0df7434c43130e0217b67625c8a2155a78301275528d79b281b"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GDAL.v3.0.2.i686-w64-mingw32-gcc7.tar.gz", "fb00d948b9c81ae95e06b27ec45120a73cc0a0252863e6e2b2eabd236d3dc1bb"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.2.powerpc64le-linux-gnu.tar.gz", "234c0edbd5bb3c33592c2c306017a351918da59823247f063742c848b369cee7"),
    MacOS(:x86_64) => ("$bin_prefix/GDAL.v3.0.2.x86_64-apple-darwin14.tar.gz", "9bb07ff7b07e71aadf106f815b52193b8a1409f4eec0d63090d6d71c7d60d197"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.2.x86_64-linux-gnu.tar.gz", "8d8f65f76f97f36a93905771f53f152d513dfa93556caa08cf2dab9fd9f62ced"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/GDAL.v3.0.2.x86_64-linux-musl.tar.gz", "09e34a52bb4ac4d942a059a7f6642ddbd3d3e84e918e413acfec9a8ea13465d5"),
    FreeBSD(:x86_64) => ("$bin_prefix/GDAL.v3.0.2.x86_64-unknown-freebsd11.1.tar.gz", "c8e93eb5b64cb6bd42bdad789c84b559391e3b2ba336c8ed06fa12e8fb50b1fa"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GDAL.v3.0.2.x86_64-w64-mingw32-gcc7.tar.gz", "6f26752b99811f359ff9494509c51e8f8e5aaf70091f1be1d9988d41cc573995"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_gdal.jl"), products, verbose=verbose)

function include_deps(name)
    """
    module $name
        import Libdl
        path = joinpath(@__DIR__, $(repr(string("deps_", name, ".jl"))))
        isfile(path) || error("$name wasn't build correctly. Please run Pkg.build(\\\"GDAL\\\")")
        include(path)
    end
    using .$name
    """
end

open("deps.jl", "w") do io
    for dep in (:zlib, :geos, :sqlite, :proj, :mbedtls, :gdal)
        println(io, include_deps(dep))
    end
    println(io, """
    const libgdal = gdal.libgdal
    const libproj = proj.libproj
    function check_deps()
        zlib.check_deps()
        geos.check_deps()
        sqlite.check_deps()
        proj.check_deps()
        mbedtls.check_deps()
        gdal.check_deps()
    end
    """)
end
