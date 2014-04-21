#download pictures from http://www.charbase.com/images/glyph/...
use strict;
use warnings;

my @blocks = (
		#~ [ 'autres', 			127744, 128511],
		#~ [ 'transport', 		128640, 128709],
		#~ [ 'emoticon', 		128513, 128591],
		[ 'technical', 		8960, 9203],
		[ 'math-ops', 		8704, 8959],
		[ 'arrows', 		8592, 8703],
		[ 'arrows2', 		10224, 10239],
		[ 'arrows3', 		10496, 10623],
		[ 'num-forms', 		8528, 8585],
		[ 'geo-shapes', 		9632, 9727],
		[ 'ctrl-pict-block', 		9216, 9254],
		[ 'symbols-block', 		9728, 9983],
		[ 'dingbats', 		9985, 10175],
		[ 'braille', 		10240, 10495],
		[ 'boxes', 		9472, 9599],
		[ 'arabic', 		1536, 1791],
		[ 'hebrew', 		1425, 1524],
		[ 'KATAKANA', 		12448, 12543],
	);
my $filler = " " x 40;
foreach my $block ( @blocks ){
	my ($name, $start, $end) = @$block;
	mkdir $name unless -d $name;
	chdir $name;
	for($start .. $end){
		print "\r$filler\r$name : $_ ";
		next if -e "$_.png";
		`wget -q http://www.charbase.com/images/glyph/$_`;
		if((stat $_)[7] == 488){
			unlink $_;
			next;
		}
		`ren $_ $_.png`;
	}
	print "\r$filler\r$name ok\n";
	chdir '..';
}
print "\nFinished\n\a\a\a";