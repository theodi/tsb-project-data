require 'spec_helper'

describe ProjectCSV do

  before do
    `RAILS_ENV=test REPLACE_SUPPORTING=true INPUT_FILENAME='datatest100.xlsx' rake loader:complete_load `
  end

  describe

  end

end