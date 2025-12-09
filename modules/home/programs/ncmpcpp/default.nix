{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixsys.home.programs.ncmpcpp;
in
{
  options.nixsys.home.programs.ncmpcpp = {
    enable = lib.mkEnableOption "nixsys.home.programs.ncmpcpp";
    package = lib.mkPackageOption pkgs "ncmpcpp" { };
  };

  config = lib.mkIf cfg.enable {
    programs.ncmpcpp = {
      enable = true;

      mpdMusicDir = config.nixsys.home.services.mpd.music-directory;
      package = cfg.package.override {
        visualizerSupport = true;
      };
      settings = {
        alternative_header_first_line_format = "$b$1$aqqu$/a$9 {%t}|{%f} $1$atqq$/a$9$/b";

        browser_display_mode = "columns";

        color1 = "white";
        colors_enabled = "yes";

        display_volume_level = "yes";
        display_bitrate = "yes";
        display_remaining_time = "yes";
        header_visibility = "no";
        main_window_color = "white";
        ignore_leading_the = "yes";

        song_columns_list_format = "(7f)[green]{l} (25)[cyan]{a} (40)[]{t|f} (30)[red]{b}";
        song_library_format = "{%d.}{%n - }{%t}";
        song_list_format = "{%a - }{%t}|{$8%f$9}$R{$3(%l)$9}";
        song_status_format = "{{%a{ \"%b\"{ (%y)}} - }{%t}}|{%f}";
        song_window_title_format = "{%a - }{%t}|{%f}";

        playlist_display_mode = "columns";
        progressbar_look = "=|";
        progressbar_color = "yellow";
        statusbar_color = "yellow";

        titles_visibility = "no";
        user_interface = "alternative";

        visualizer_data_source = config.nixsys.home.services.mpd.fifo-file;
        visualizer_output_name = "fifo";
        visualizer_in_stereo = "yes";
        visualizer_type = "spectrum";
        visualizer_look = "∙▋";
      };
    };
  };
}
