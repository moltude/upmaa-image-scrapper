# perl script to scrape all of the images from penn.museun/collections/

#!/usr/local/bin/perl
use warnings;
#use strict; 
use feature qw(say);
use FindBin;
use Data::Dumper;
use File::Basename;
use File::Spec;
use File::Path;
use LWP::Simple;
use WWW::Mechanize;
use Try::Tiny;


# read the file urls from data.csv
# reformat to _1600.jpg
# download image to /object_id_images/

sub download_images( $_ ) {
	$objectID = shift;
	$obj_url = shift;

	$mech = WWW::Mechanize->new();
	
	do {
		eval {
			$mech->get( $obj_url );
		};
	} while (not $mech->res->is_success);
	
	my @links = $mech->links();
	for my $link ( @links ) {
		if($link->url =~ /s\/assets\//) {
			$d_path = "./penn_museum_object_images/" . $objectID . "/";
			eval(mkpath($d_path));
			if(@_) {
				say "Could not make file path ";
			}
			say 'Found downloading image link...';
			$tmp_url = $link->url;
			# replace the url from 800 to 1600
			$tmp_url =~ s/\_800/\_1600/g ;
			#say $tmp_url;
			my $file = $d_path . basename($tmp_url);
			getstore($tmp_url, $file);
			say File::Spec->rel2abs($file);
		}
	}
}

# begin sub
sub load_emu_data( $ ) {
	my $edata = shift;
	open (EMU_EXPORT, 'C:\\Users\\reg1\\Desktop\\all-latest\\web_image_export.csv') or die $!;
	while (<EMU_EXPORT>) {
		chomp;
		(my $emuobjectid, my $url) = split(",");
		say $emuobjectid;
		download_images($emuobjectid, $url);
		#say $url;
		#($emuobjectid) = $emuobjectid =~ /"([^"]*)"/;
		# $emuobjectid = uc($emuobjectid);
		#$edata->{ $emuobjectid } = {
		#		objectid => $emuobjectid,
		#		url => $url,
		#	};
		#
	}
	return $edata;
}
#end sub



# CHANGE THIS to download images for a new object		
# my $obj_url = "http://penn.museum/collections/object/148826";
# CHANGE THIS PATH TO BE THE OBJECT ID
#$d_path = "./c450/";


my %emudata; 
# load emu catalog data
$emudata_ref = load_emu_data(\%emudata);
%emudata = %$emudata_ref;
say "EMu data loaded";

# say Dumper(%emudata);

#foreach my $obj_id ( keys %emudata ) {
#	say "Attempting to download " . $obj_id;
#	say Dumper($emudata{$obj_id});
#	download_image($obj_id, $emudata{$obj_id}->url);
#}