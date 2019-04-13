using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Example taken from
# https://github.com/JuliaIO/ImageMagick.jl/blob/sd/binaryprovider/deps/build.jl
dependencies = [
    "build_Zlib.v1.2.11.jl",
    "build_MbedTLS.v2.13.1.jl",
    "build_GEOS.v3.7.1.jl",
    "build_PROJ.v5.2.0.jl",
    "build_SQLiteBuilder.v0.1.0.jl",
    "build_LibCURL.v7.64.0.jl",
]

# set here and commented out in all other build*.jl files
const verbose = true

for elem in dependencies
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process
    m = Module(:__anon__)
    Core.eval(m, :(Main.include($(joinpath(@__DIR__, elem)))))
end

# Parse some basic command-line arguments
# const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgdal"], :libgdal),
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
bin_prefix = "https://github.com/JuliaGeo/GDALBuilder/releases/download/v2.4.1-0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/GDAL.v2.4.1.aarch64-linux-gnu.tar.gz", "1bf573effa2998bc3422a673b0e6cdac18cf7e48d7e67e1963f411a3dad1bffe"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/GDAL.v2.4.1.arm-linux-gnueabihf.tar.gz", "2f682ea6b05027fc2f3b7c1e9ffa8caa2acba7498aea7aa607d0000e1ebb6a84"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/GDAL.v2.4.1.i686-linux-gnu.tar.gz", "8199e4112f4f70f91c4c16e3c5b5fd49b112622e4598c6209a9ff50c6caf2157"),
    Windows(:i686) => ("$bin_prefix/GDAL.v2.4.1.i686-w64-mingw32.tar.gz", "0a900272299a96b8cc9fbdf26e1389187131f46e8e9a887e1784897b901a1d1d"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/GDAL.v2.4.1.powerpc64le-linux-gnu.tar.gz", "375a43743b9703db077701bb0c09593ac5f0a1a6ba0a585d1f52058f93e7ce0b"),
    MacOS(:x86_64) => ("$bin_prefix/GDAL.v2.4.1.x86_64-apple-darwin14.tar.gz", "6e9ceeed050f91e82a7d589384ff398610c245a7c2405c74dc42b9a0a245d94b"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/GDAL.v2.4.1.x86_64-linux-gnu.tar.gz", "396f21cd4b3ce13e93e546b16eb9501320c294cc94aa7758bd410bf34a946566"),
    Windows(:x86_64) => ("$bin_prefix/GDAL.v2.4.1.x86_64-w64-mingw32.tar.gz", "3c95dc0786a8327a9138b4196413d7dd5b299d187fd51603ed7ad4110a5adf2c"),
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
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
