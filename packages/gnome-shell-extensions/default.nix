{prev, final, ...}: {
  clipboard-indicator = final.callPackage prev.gnomeExtensions.buildShellExtension {
    name = "clipboard-indicator";
    uuid = "clipboard-indicator@tudmotu.com";
    pname = "clipboard-indicator";

    description = "The most popular clipboard manager for GNOME, with over 1M downloads";
    link = "https://extensions.gnome.org/extension/779/clipboard-indicator/";
    version = 65;
    sha256 = "HO28VKvuVSG5w3S5SBM9ocraKWCL+CrJYP0ef4k6fKM=";

    # Hex-encoded string of JSON bytes
    metadata = "ewogICJfZ2VuZXJhdGVkIjogIkdlbmVyYXRlZCBieSBTd2VldFRvb3RoLCBkbyBub3QgZWRpdCIsCiAgImRlc2NyaXB0aW9uIjogIlRoZSBtb3N0IHBvcHVsYXIgY2xpcGJvYXJkIG1hbmFnZXIgZm9yIEdOT01FLCB3aXRoIG92ZXIgMU0gZG93bmxvYWRzIiwKICAiZ2V0dGV4dC1kb21haW4iOiAiY2xpcGJvYXJkLWluZGljYXRvciIsCiAgIm5hbWUiOiAiQ2xpcGJvYXJkIEluZGljYXRvciIsCiAgInNldHRpbmdzLXNjaGVtYSI6ICJvcmcuZ25vbWUuc2hlbGwuZXh0ZW5zaW9ucy5jbGlwYm9hcmQtaW5kaWNhdG9yIiwKICAic2hlbGwtdmVyc2lvbiI6IFsKICAgICI0NiIsCiAgICAiNDciCiAgXSwKICAidXJsIjogImh0dHBzOi8vZ2l0aHViLmNvbS9UdWRtb3R1L2dub21lLXNoZWxsLWV4dGVuc2lvbi1jbGlwYm9hcmQtaW5kaWNhdG9yIiwKICAidXVpZCI6ICJjbGlwYm9hcmQtaW5kaWNhdG9yQHR1ZG1vdHUuY29tIiwKICAidmVyc2lvbiI6IDY1Cn0=";
  };
}
