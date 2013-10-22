namespace :viz do

  desc 'renders static versions of the visualisations for IE8 and below'
  task render_static: :environment do
    puts "Rendering static visualisations..."

    capture_js_path = Rails.root.join('vendor', 'assets', 'javascripts', 'capture.js')

    viz_ary = [
      { path: "/viz", file: "home.png", width: 1170, height: 480 }
    ]
    
    viz_ary.each_with_index do |viz, n|
      `phantomjs #{capture_js_path} http://localhost:3000#{viz[:path]} #{Rails.root.join('public', 'viz', viz[:file])} #{viz[:width]} #{viz[:height]}`
      puts "Rendered viz #{n+1} of #{viz_ary.length}"
    end
  end

end