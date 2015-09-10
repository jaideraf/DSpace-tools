#!/usr/bin/perl
###########################################################################
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
# http://www.gnu.org/copyleft/gpl.html
#
# Description : Deduplicate CSV values 
# 
# Author: Oberdan Luiz May
#
# Last update: 2015-09-10
###########################################################################

use strict;
use warnings;
use Text::CSV;
use Tie::IxHash;

#Inicializa o parser de csv
my $csv_parser = Text::CSV->new( { binary     => 1, 
		                   sep_char   => ',', 
				   quote_char => '"' } );

open( my $in  , '<:encoding(utf-8)' , '11449-1.csv' );
open( my $out , '>:encoding(utf-8)' , 'dedup.csv' );

while( my $row = $csv_parser->getline($in) ){
   my $i = 5;
#   for( my $i = 0 ; $i < 66 ; $i++ ){
      if( $$row[$i] =~ /\|\|/ ){
          #Quebra no ||
	  my @parts = split(/\|\|/,$$row[$i]);
	  my %count = ();
          #Os dados ficam na ordem em que entram
	  tie(%count,'Tie::IxHash');
          #Conta ocorrencias das partes
	  foreach my $part (@parts){
	    $count{$part}++;
	  };
          
	  my $have_dup = 0;
	  foreach my $part (keys %count){
	    if( $count{$part} > 1 ){
	      print "Check $$row[0] -> $i -> $$row[$i]\n";
	      $have_dup = 1;
	      last;
            };
	  };

	 if( $have_dup ){
            print $out qq/"$$row[0]","/ , join('||',keys(%count)) , qq/"\n/;
	 };	 
      };
#   };
};
$csv_parser->error_diag();

close( $in );
close( $out );
exit(0);
