{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  fetchFromGitLab,
  glib,
  cmake,
  libfprint,
  polkit,
  systemd,
  dbus,
  pam,
  libxslt,
  perl,
  libpam-wrapper,
}:
stdenv.mkDerivation rec {
  pname = "pam-fprint-grosshack";
  version = "0.1.0";

  src = fetchFromGitLab {
    owner = "mishakmak";
    repo = "pam-fprint-grosshack";
    rev = "grosshack";
    hash = "sha256-obczZbf/oH4xGaVvp3y3ZyDdYhZnxlCWvL0irgEYIi0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
  ];

  buildInputs = [
    glib
    libfprint
    polkit
    systemd
    dbus
    pam
    libxslt
    perl # for pod2man
    libpam-wrapper
  ];

  env = {
    # HACK: We want to install policy files files to $out/share but polkit
    # should read them from /run/current-system/sw/share on a NixOS system.
    # Similarly for config files in /etc.
    # With autotools, it was possible to override Make variables
    # at install time but Meson does not support this
    # so we need to convince it to install all files to a temporary
    # location using DESTDIR and then move it to proper one in postInstall.
    DESTDIR = "dest";
  };

  mesonFlags = ["--sysconfdir /etc"];

  postInstall = ''
    mkdir -p $out/lib/security/
    cp $DESTDIR/lib/security/pam_fprintd_grosshack.so $out/lib/security/pam_fprintd_grosshack.so
  '';

  meta = with lib; {
    description = "Description of your C library";
    homepage = "https://gitlab.com/mishakmak/pam-fprint-grosshack";
    license = licenses.mit; # Adjust the license accordingly
    platforms = platforms.unix;
    maintainers = with maintainers; [
      /*
      add yourself
      */
    ];
  };
}
