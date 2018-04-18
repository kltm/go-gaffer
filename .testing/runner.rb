####
#### ruby ./.testing/runner.rb
####
#### TODO: Put output somewhere.
#### TODO: Add the ontobio stuff/tests/etc.
####


require 'yaml'
template_yaml = YAML.load_file('template.yaml')
puts template_yaml['datasets']

id = template_yaml['id']
template_yaml['datasets'].each do |o|

  commands = []

  #id = o['id']
  type = o['type']
  source = o['source']
  compression = o['compression']

  ## Cleaning commands.
  commands.push("rm #{ id }-*.gaf || true")
  commands.push("rm #{ id }-*.txt || true")
  commands.push("rm #{ id }-*.json || true")
  commands.push("rm #{ id }.gaf || true")
  commands.push("rm #{ id }.gaf.gz || true")

  if type.eql?("gaf")
    if compression and compression.eql? "gzip"
      commands.push("curl #{ source } > #{ id }.gaf.gz")
      commands.push("gunzip #{ id }.gaf.gz")
    else
      commands.push("curl #{ source } > #{ id }.gaf")
    end

    commands.push("./owltools --log-warning go-gaf.owl --gaf #{ id }.gaf --createReport --gaf-report-file #{ id }-owltools-check.txt --gaf-report-summary-file #{ id }-summary.txt --gaf-prediction-file #{ id }-prediction.gaf --gaf-prediction-report-file #{ id }-prediction-report.txt --gaf-validation-unsatisfiable-module #{ id }-incoherent.owl --experimental-gaf-prediction-file #{ id }-prediction-experimental.gaf --experimental-gaf-prediction-report-file #{ id }-prediction-experimental-report.txt --gaf-run-checks || echo 'errors found'")

    ## Run commands.
    commands.each do |cmd|
      puts cmd
      puts `#{ cmd }`
      if not $?.success?
        abort('ERROR in checks')
      end
    end

    ## WARNING: Lamd. Try and dump output.
    ["#{ id }-owltools-check.txt", "#{ id }-summary.txt", "#{ id }-prediction.gaf", "#{ id }-prediction-report.txt", "#{ id }-incoherent.owl", "#{ id }-prediction-experimental.gaf" ,"#{ id }-prediction-experimental-report.txt"].each do |f|
      puts f
      puts `cat #{ f}`
    end

  end

end
