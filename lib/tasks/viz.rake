namespace :viz do

  desc 'renders static versions of the visualisations for IE8 and below'
  task :render_static, [:domain] => :environment do |task, args|
    capture_js_path = Rails.root.join('vendor', 'assets', 'javascripts', 'capture.js')

    viz_ary = [
      { path: "/viz", file: "home.png", width: 1170, height: 480 }
    ]

    viz_ary.each_with_index do |viz, n|
      puts "phantomjs #{capture_js_path} http://#{args.domain}#{viz[:path]} #{Rails.root.join('public', 'viz', viz[:file])} #{viz[:width]} #{viz[:height]} 5000"

      `phantomjs #{capture_js_path} http://#{args.domain}#{viz[:path]} #{Rails.root.join('public', 'viz', viz[:file])} #{viz[:width]} #{viz[:height]} 5000`
    end
  end

end