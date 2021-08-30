fakeroot_build() {
  local debian_pkgver \
        package_filename \

  source "${FILE}"

  for package in ${pkgname[@]}; do
    msg "Creating package \"${package}\"..."
    unset depends optdepends conflicts provides replaces license

    cd "pkg/${package}/"
    get_variables

    # Remove epoch from package version for built package, as packages built
    # with standard Debian build tools also do such.
    debian_pkgver="$(echo "${pkgver}" | sed 's|^[^:]*:||')"

    # Purge the existing directory, and extract the archive built by makepkg
    # so that we have correct permissions.
    cd ../
    rm "${package}" -rf
    mkdir "${package}"

    package_filename="${package}-${pkgver}-${makepkg_arch}.${package_extension}"
    tar -xf "../${package_filename}" -C "${package}/"
    rm "../${package_filename}"

    # Set up Debian package directory structure
    mkdir -p "${package}/DEBIAN/"
    touch "${package}/DEBIAN/control"

    # Enter package directory
    cd "${package}/"

    # Set package version
    convert_version

    # Delete built package if it exists.
    if find ../../"${package}_${debian_pkgver}_${makedeb_arch}.deb" &> /dev/null; then
      warning2 "Built package detected. Removing..."
      rm ../../"${package}_${debian_pkgver}_${makedeb_arch}.deb"
    fi

    # Convert dependencies, then export data to control file.
    check_distro_dependencies
    remove_dependency_description
    generate_optdepends_fields
    run_dependency_conversion

    msg2 "Generating control file..."
    generate_control "../../${FILE}" ./DEBIAN/control

    add_install_scripts

    # Remove leftover build files from makepkg.
    # We don't print a message for this, as there's some spots in makepkg that
    # might make it look redundant.
    for i in '.BUILDINFO' '.MTREE' '.PKGINFO' '.INSTALL' '.Changelog'; do
      rm -f "${i}"
    done

    cd ..

    # Compress into Debian archive.
    cd "${package}"
    msg2 "Compressing package..."
    pkgver="${debian_pkgver}" \
      build_deb "${package}"

    mv "${package}_${debian_pkgver}_${makedeb_arch}.deb" ../../

    cd ../..
  done

  msg "Leaving fakeroot environment..."
}
