using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
# const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgeos_c"], :libgeos),
    LibraryProduct(prefix, ["libgeos"], :libgeos_cpp),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaGeo/GEOSBuilder/releases/download/v3.7.1-5"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.aarch64-linux-gnu-gcc4.tar.gz", "a3423dcc781f6ba93d097ad29d39ca7ed69b7571657fddbfca36c503d7fadb3e"),
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.aarch64-linux-gnu-gcc7.tar.gz", "32c886ea9b906dcb0694ca85750094bf9816bee96cb30f1b9ff2b9fd96cf9499"),
    Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.aarch64-linux-gnu-gcc8.tar.gz", "a91325eedc5182ce362b91749a8d385dac87644297d8855d00964aac73734125"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.aarch64-linux-musl-gcc4.tar.gz", "aa21a7d363da24e07e3d3586d7af71c792d43f8a81897e8b68941a937e19b880"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.aarch64-linux-musl-gcc7.tar.gz", "28c8f6ff370fafeb9c2a1589521c7a42397b23b9638eafd05f6fe9ccaeb9b751"),
    Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.aarch64-linux-musl-gcc8.tar.gz", "d3afe5502c0bf80e4c85383a3ff065ca1e138c7d829b97dc17c7c9d365115063"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.arm-linux-gnueabihf-gcc4.tar.gz", "46919b6d9c6d803367a41e8ddcfbd93d526ebf6e8d013c00341941dc1fc46d61"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.arm-linux-gnueabihf-gcc7.tar.gz", "397765670cdbb0c5c06910ad3b26668a4cb03d9c5e645df54f37780625da4dc0"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.arm-linux-gnueabihf-gcc8.tar.gz", "efda5eae35c0ba45fb623136acd9875d78f4b92a9a96d7396c379e924040b5e5"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.arm-linux-musleabihf-gcc4.tar.gz", "8f0f2c639a280d18ab5f31105e42277163f687f2ca357e8e7a54cd39c3217e0a"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.arm-linux-musleabihf-gcc7.tar.gz", "c8f777d58542bf86a92c6fef02e4a4216d2f3a3abb84d16db78775729f188b1b"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.arm-linux-musleabihf-gcc8.tar.gz", "dfcb96a8e48a13e147fb4de9616e0379ea92183091b162e1923879efc3044aab"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.i686-linux-gnu-gcc4.tar.gz", "68cb9d5b3757e528790c5fbcbbe7b424b7dac921a9271711ebf03cb1142fcbfa"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.i686-linux-gnu-gcc7.tar.gz", "a08b828634d824d5f3a084c83f378040440dfbc070d6b0ec3ebc8d1bf3d595e2"),
    Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.i686-linux-gnu-gcc8.tar.gz", "03d745375e606de0fc513883da1edb5421cd8091f87d9a37bd79cb79d34eb655"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.i686-linux-musl-gcc4.tar.gz", "9ccda401be42199b65c5e0633558297e2d3db2b46ba471cd3ac1ab32f345e20c"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.i686-linux-musl-gcc7.tar.gz", "9439358fecad01239e7934c4f5c9c0f3da0ea1de16a1fb86ec3aed8314e10627"),
    Linux(:i686, libc=:musl, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.i686-linux-musl-gcc8.tar.gz", "9b59a6c44e5ce072ec22d49f526bce6bca48bdf652381c274e7de96b44bb793b"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.i686-w64-mingw32-gcc4.tar.gz", "fbf2e71df8e3e4b354a56f38b2919cb171273095096dea98779d8f9cdec0abef"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.i686-w64-mingw32-gcc7.tar.gz", "cb9f624403c2d98aa6146483a80c6fe2722188fb080ac3b74cc16f6248d918ad"),
    Windows(:i686, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.i686-w64-mingw32-gcc8.tar.gz", "b2bb19dadd211bc0a3475d3b6fd2acdef0bf80ff038fc1153b87c69da9571909"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.powerpc64le-linux-gnu-gcc4.tar.gz", "1340a5f7930043c3c77c835868e4bcd3c5aeb9a87b7ff2e8157c2c825eba2e75"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.powerpc64le-linux-gnu-gcc7.tar.gz", "b47f71135fc4b087b0ab836d17a3b4d8fc73291b47490fee6a760c5786b4fbc9"),
    Linux(:powerpc64le, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.powerpc64le-linux-gnu-gcc8.tar.gz", "a652af9d30e0a462457917ec2bb6ed00106d12e5d18cc2fc7ad0e1824d2dbeb9"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-apple-darwin14-gcc4.tar.gz", "eb48b44cbdfe63a29dab542167e7d1f8ba01ea19d2205a6f880797b67b95cb72"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-apple-darwin14-gcc7.tar.gz", "d1176184ec5ba96193dba67f077e32ec288eaadf7c3e15106a75b9df0c33d2ca"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-apple-darwin14-gcc8.tar.gz", "cc912a186cf8e9095fc5fdd18fb1abc922024a16dfcb55951037b3b0cfe9fc94"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-linux-gnu-gcc4.tar.gz", "2db4a9b2eb072ab3049606285da8eef9ad7c00aa7e4526cb0b04490f1db8c4bb"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-linux-gnu-gcc7.tar.gz", "e4cd8977dced3df69e878ffaa08ba32e74e6e8980dff8bf50b5d0851e580a532"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-linux-gnu-gcc8.tar.gz", "170b67d3cc33a4295435ceca6664d90427535338581cadd544052934eae25cd6"),
    # removed compiler_abi as suggested in https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407#issuecomment-473688254
    # such that GCC4 platforms will also pick up this GCC7 build, ref https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/387
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/GEOS.v3.7.1.x86_64-linux-musl-gcc7.tar.gz", "e0679868f801778a5e977067004afce8fb46b7b080f362753d6e7d142d34bcbb"),
    Linux(:x86_64, libc=:musl, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-linux-musl-gcc8.tar.gz", "22842e1421a224ee2d79eab91ebbc96138a14fa667d76a50bcaf0782359ac404"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-unknown-freebsd11.1-gcc4.tar.gz", "4b5728203b8d29a3b4091052c218408542071c412580299becffaf86ee52ec1e"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-unknown-freebsd11.1-gcc7.tar.gz", "1588b1cea55903a0c495e689a3bfdf2a285dd35eba94063192cdea8356d1c7d2"),
    FreeBSD(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-unknown-freebsd11.1-gcc8.tar.gz", "ffb0192bd7d6917f996b00e22e733ff52f13351a22d816d25b64e2824bd8e790"),
    # removed compiler_abi as suggested in https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407#issuecomment-473688254
    # such that GCC4 platforms will also pick up this GCC7 build, ref https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407
    Windows(:x86_64) => ("$bin_prefix/GEOS.v3.7.1.x86_64-w64-mingw32-gcc7.tar.gz", "821b897653d83bae25750733e804991bebdb78599659eef45fdd62afd5b7f7af"),
    Windows(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GEOS.v3.7.1.x86_64-w64-mingw32-gcc8.tar.gz", "78d1eb282d06d803b8a32cac0d80080c225fc193883f5575bcd6ba5c40249ba8"),
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
    # ignore_platform is set to true to allow installing the GCC7 builds on GCC4
    # platforms, because of issues with x86_64-linux-musl-gcc4 and x86_64-w64-mingw32-gcc4
    install(dl_info...; prefix=prefix, force=true, verbose=verbose, ignore_platform=true)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
