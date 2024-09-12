# frozen_string_literal: true

require 'test_helper'

class Detector
  class StandardIdentifiersTest < ActiveSupport::TestCase
    test 'ISBN detected in a string' do
      actual = Detector::StandardIdentifiers.new('test 978-3-16-148410-0 test').identifiers

      assert_equal('978-3-16-148410-0', actual[:isbn])
    end

    test 'ISBN-10 examples' do
      # from wikipedia
      samples = ['99921-58-10-7', '9971-5-0210-0', '960-425-059-0', '80-902734-1-6', '85-359-0277-5',
                 '1-84356-028-3', '0-684-84328-5', '0-8044-2957-X', '0-85131-041-9', '93-86954-21-4', '0-943396-04-2',
                 '0-9752298-0-X']

      samples.each do |isbn|
        actual = Detector::StandardIdentifiers.new(isbn).identifiers

        assert_equal(isbn, actual[:isbn])
      end
    end

    test 'ISBN-13 examples' do
      samples = ['978-99921-58-10-7', '979-9971-5-0210-0', '978-960-425-059-0', '979-80-902734-1-6', '978-85-359-0277-5',
                 '979-1-84356-028-3', '978-0-684-84328-5', '979-0-8044-2957-X', '978-0-85131-041-9', '979-93-86954-21-4',
                 '978-0-943396-04-2', '979-0-9752298-0-X']

      samples.each do |isbn|
        actual = Detector::StandardIdentifiers.new(isbn).identifiers

        assert_equal(isbn, actual[:isbn])
      end
    end

    test 'not ISBNs' do
      samples = ['orange cats like popcorn', '1234-6798', 'another ISBN not found here']

      samples.each do |notisbn|
        actual = Detector::StandardIdentifiers.new(notisbn).identifiers

        assert_nil(actual[:isbn])
      end
    end

    test 'ISBNs need boundaries' do
      samples = ['990026671500206761', '979-0-9752298-0-XYZ']
      # note, there is a theoretical case of `asdf979-0-9752298-0-X` returning as an ISBN 10 even though it doesn't
      # have a word boundary because the `-` is treated as a boundary so `0-9752298-0-X` would be an ISBN10. We can
      # consider whether we care in the future as we look for incorrect real-world matches.

      samples.each do |notisbn|
        actual = Detector::StandardIdentifiers.new(notisbn).identifiers

        assert_nil(actual[:isbn])
      end
    end

    test 'ISSNs detected in a string' do
      actual = Detector::StandardIdentifiers.new('test 0250-6335 test').identifiers

      assert_equal('0250-6335', actual[:issn])
    end

    test 'ISSN examples' do
      samples = %w[0250-6335 0000-0019 1864-0761 1877-959X 0973-7758 1877-5683 1440-172X 1040-5631]

      samples.each do |issn|
        actual = Detector::StandardIdentifiers.new(issn).identifiers

        assert_equal(issn, actual[:issn])
      end
    end

    test 'not ISSN examples' do
      samples = ['orange cats like popcorn', '12346798', 'another ISSN not found here', '99921-58-10-7']

      samples.each do |notissn|
        actual = Detector::StandardIdentifiers.new(notissn).identifiers

        assert_nil(actual[:issn])
      end
    end

    test 'ISSNs need boundaries' do
      actual = Detector::StandardIdentifiers.new('12345-5678 1234-56789').identifiers

      assert_nil(actual[:issn])
    end

    test 'ISSN validate rejects ISSNs with wrong check digit' do
      samples = %w[
        1234-5678
        2015-2016
        1460-2441
        1460-2442
        1460-2443
        1460-2444
        1460-2445
        1460-2446
        1460-2447
        1460-2448
        1460-2449
        1460-2440
        0250-6331
        0250-6332
        0250-6333
        0250-6334
        0250-6336
        0250-6337
        0250-6338
        0250-6339
        0250-6330
        0250-633x
        0250-633X
      ]
      samples.each do |notissn|
        actual = Detector::StandardIdentifiers.new(notissn).identifiers

        assert_nil(actual[:issn])
      end
    end

    test 'ISSN validate method accepts ISSNs with correct check digit' do
      samples = %w[
        1460-244X
        2015-223x
        0250-6335
        0973-7758
      ]
      samples.each do |issn|
        actual = Detector::StandardIdentifiers.new(issn).identifiers

        assert_equal(issn, actual[:issn])
      end
    end

    test 'doi detected in string' do
      actual = Detector::StandardIdentifiers.new('"Quantum tomography: Measured measurement", Markus Aspelmeyer, nature physics "\
                                       "January 2009, Volume 5, No 1, pp11-12; [ doi:10.1038/nphys1170 ]').identifiers

      assert_equal('10.1038/nphys1170', actual[:doi])
    end

    test 'doi examples' do
      samples = %w[10.1038/nphys1170 10.1002/0470841559.ch1 10.1594/PANGAEA.726855 10.1594/GFZ.GEOFON.gfz2009kciu
                   10.1594/PANGAEA.667386 10.3207/2959859860 10.3866/PKU.WHXB201112303 10.1430/8105 10.1392/BC1.0]

      samples.each do |doi|
        actual = Detector::StandardIdentifiers.new(doi).identifiers

        assert_equal(doi, actual[:doi])
      end
    end

    test 'not doi examples' do
      samples = ['orange cats like popcorn', '10.1234 almost doi', 'another doi not found here', '99921-58-10-7']

      samples.each do |notdoi|
        actual = Detector::StandardIdentifiers.new(notdoi).identifiers

        assert_nil(actual[:notdoi])
      end
    end

    test 'pmid detected in string' do
      actual = Detector::StandardIdentifiers.new('Citation and stuff PMID: 35648703 more stuff.').identifiers

      assert_equal('PMID: 35648703', actual[:pmid])
    end

    test 'pmid examples' do
      samples = ['PMID: 35648703', 'pmid: 1234567', 'PMID:35648703']

      samples.each do |pmid|
        actual = Detector::StandardIdentifiers.new(pmid).identifiers

        assert_equal(pmid, actual[:pmid])
      end
    end

    test 'not pmid examples' do
      samples = ['orange cats like popcorn', 'pmid:almost', 'PMID: asdf', '99921-58-10-7']

      samples.each do |notpmid|
        actual = Detector::StandardIdentifiers.new(notpmid).identifiers

        assert_nil(actual[:pmid])
      end
    end
  end
end