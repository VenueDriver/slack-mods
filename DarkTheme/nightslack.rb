#!/usr/bin/env ruby
slack_pid = `ps -axcf -S -O%cpu | grep Slack | awk '{print $2}' | head -n 1`.strip
unless slack_pid.empty?
  `kill -9 #{slack_pid}`
end
js_code = <<EOF
document.addEventListener('DOMContentLoaded', function() {
 $.ajax({
   url: 'https://raw.githubusercontent.com/VenueDriver/slack-mods/master/DarkTheme/black.css',
   success: function(css) {
     css += `
       div.c-virtual_list__scroll_container {
           background-color: #0E0F0F !important;
       }
       .p-message_pane .c-message_list:not(.c-virtual_list--scrollbar), .p-message_pane .c-message_list.c-virtual_list--scrollbar > .c-scrollbar__hider {
            z-index: 0;
       }
       div.c-message__content:hover {
           background-color: #0E0F0F !important;
       }

       div.c-message:hover {
           background-color: #0E0F0F !important;
       }
     `;
     $("<style></style>").appendTo('head').html(css);
   }
 });
});
EOF

@file_target = '/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js'
`cp #{@file_target} #{@file_target}.bak`
@current_file = File.read(@file_target)
@normal_mode = @day_mode_set ? @current_file : @current_file.split(js_code).first
@night_mode = @normal_mode + js_code

use_day_mode = ARGV[0] == '-d'
def set_mode(mode)
  if mode == 'd'
    File.open(@file_target, 'w'){|f| f.puts @normal_mode}
		puts "Slack Normal (day) mode has been set!"
  else
    File.open(@file_target, 'w'){|f| f.puts @night_mode}
		puts "Slack Normal night mode has been set!"
  end
end

use_day_mode ? set_mode('d') : set_mode('n')

`open -a "Slack"`
