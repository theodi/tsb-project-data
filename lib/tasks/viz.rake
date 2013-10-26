namespace :viz do

  desc 'renders static versions of the visualisations for IE8 and below'
  task :render_static, [:domain] => :environment do |task, args|

    `mkdir -p #{Rails.root.join('public', 'viz')}`

    capture_js_path = Rails.root.join('vendor', 'assets', 'javascripts', 'capture.js')

    viz_ary = [
      { path: "/viz", file: "home.png", width: 1170, height: 485 }
    ]

    viz_ary.each_with_index do |viz, n|
      `phantomjs #{capture_js_path} http://#{args.domain}#{viz[:path]} #{Rails.root.join('public', 'viz', viz[:file])} #{viz[:width]} #{viz[:height]} 5000`
    end
  end

end