#!/usr/bin/perl -w


use strict;

my @date = split //,`today_yesterday.rb`;

my $today = $date[6].$date[7];

my $month = $date[4].$date[5];

my $year = $date[0].$date[1].$date[2].$date[3];

my $yday = $date[14].$date[15];

my $ymonth = $date[12].$date[13];

my $yyear = $date[8].$date[9].$date[10].$date[11];
    
my $date = $year . $month . $today;

my $new_file = $date . "_soprld203_new.txt";

my @files = glob "*.xml";

foreach my $file (@files) {
    
    system "perl D:/Code/Perl/xml_parser_sopr_ld203.pl $file >>$new_file";
    
}