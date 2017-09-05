# encoding: utf-8
require 'spec_helper'
require 'get_pomo/mo_file'

describe GetPomo::MoFile do
  it "parses empty mo file" do
    GetPomo::MoFile.parse(File.read('spec/files/empty.mo')).should == []
  end

  it "parses empty strings" do
    GetPomo::MoFile.parse(File.read('spec/files/empty.mo')).should == []
  end

  it "reads singulars" do
    pending("singular.mo is not encoded correctly for ruby > 1.9.0") if RUBY_VERSION > "1.9.0"
    t = GetPomo::MoFile.parse(File.read('spec/files/singular.mo'))[0]
    t.to_hash.should == {:msgid=>"Back",:msgstr=>"Zurück"}
  end

  it "reads plurals" do
    t = GetPomo::MoFile.parse(File.read('spec/files/plural.mo'))[0]
    t.to_hash.should == {:msgid=>['Axis','Axis'],:msgstr=>['Achse','Achsen']}
  end

  it 'reads contexts' do
    t = GetPomo::MoFile.parse(File.read('spec/files/context.mo'))

    t[1].to_hash.should == {
      :msgid=>'Duplicate',
      :msgstr=>'Duplicado',
      :msgctxt=>'Noun',
    }

    t[2].to_hash.should == {
      :msgid=>'Duplicate',
      :msgstr=>'Duplicar',
      :msgctxt=>'Verb',
    }
  end

  describe 'instance methods' do
    it "combines multiple translations" do
      m = GetPomo::MoFile.new
      m.add_translations_from_text(File.read('spec/files/plural.mo'))
      m.add_translations_from_text(File.read('spec/files/singular.mo'))
      m.should have(2).translations
      m.translations[0].msgid.should_not == m.translations[1].msgid
    end

    it "can be initialized with translations" do
      m = GetPomo::MoFile.new(:translations=>['x'])
      m.translations.should == ['x']
    end

    it "does not generate duplicate translations" do
      second_version = File.read('spec/files/singular_2.mo')
      m = GetPomo::MoFile.new
      m.add_translations_from_text(File.read('spec/files/singular.mo'))
      m.add_translations_from_text(second_version)
      m.to_text.should == second_version
    end
  end

  it "reads metadata" do
    meta = GetPomo::MoFile.parse(File.read('spec/files/complex.mo')).detect {|t|t.msgid == ''}
    meta.msgstr.should_not be_empty
  end

  describe :to_text do
    it "writes singulars" do
      text = File.read('spec/files/singular.mo')
      GetPomo::MoFile.to_text(GetPomo::MoFile.parse(text)).should == text
    end

    it 'writes msgctxt' do
      translations = GetPomo::PoFile.parse(File.read('spec/files/context.po'))
      stream = GetPomo::MoFile.to_text(translations)

      result = GetPomo::MoFile.parse(stream)
      result[0].to_hash.should == {
        :msgid=>'Duplicate',
        :msgstr=>'Duplicado',
        :msgctxt=>'Noun',
      }

      result[1].to_hash.should == {
        :msgid=>'Duplicate',
        :msgstr=>'Duplicar',
        :msgctxt=>'Verb',
      }
    end
  end
end
