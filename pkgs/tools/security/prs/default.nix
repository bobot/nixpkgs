{ lib
, rustPlatform
, fetchFromGitLab
, installShellFiles
, pkg-config
, python3
, dbus
, glib
, gpgme
, gtk3
, libxcb
, libxkbcommon
}:

rustPlatform.buildRustPackage rec {
  pname = "prs";
  version = "0.4.1";

  src = fetchFromGitLab {
    owner = "timvisee";
    repo = "prs";
    rev = "refs/tags/v${version}";
    hash = "sha256-kElHgThpNVPzr9DSdSFjxTmJ0ivfajgk6nekGRwb2dI=";
  };

  cargoHash = "sha256-dob1WVJEPLYkPi7kPP5A6yxxe+BSRdQTgWUUiLvVlbg=";

  postPatch = ''
    # The GPGME backend is recommended
    for f in "gtk3/Cargo.toml" "cli/Cargo.toml"; do
      substituteInPlace "$f" --replace \
        'default = ["backend-gnupg-bin"' 'default = ["backend-gpgme"'
    done
  '';

  nativeBuildInputs = [ gpgme installShellFiles pkg-config python3 ];

  buildInputs = [
    dbus
    glib
    gpgme
    gtk3
    libxcb
    libxkbcommon
  ];

  postInstall = ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd prs --$shell <($out/bin/prs internal completions $shell --stdout)
    done
  '';

  meta = with lib; {
    description = "Secure, fast & convenient password manager CLI using GPG and git to sync";
    homepage = "https://gitlab.com/timvisee/prs";
    changelog = "https://gitlab.com/timvisee/prs/-/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      lgpl3Only # lib
      gpl3Only  # everything else
    ];
    maintainers = with maintainers; [ dotlambda ];
  };
}
