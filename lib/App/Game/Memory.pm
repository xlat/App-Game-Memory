package App::Game::Memory;
use 5.10.1;
use strict;
use warnings FATAL => 'all';

=head1 NAME

App::Game::Memory - a Memory Game

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use App::Game::Memory;

    my $foo = App::Game::Memory->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 start

create Window and start game.

=cut

use constant DEBUG => 0;
use constant X_CARDS => 6;
use constant Y_CARDS => 4;
use constant W_CARD => 100;
use constant H_CARD => 100;

our $face_card;
our $remaining_pairs;
our @returned_cards;
our $card_timer;

use Encode qw(from_to);
sub decode{ 
	my $str = shift; 
	from_to( $str, "utf8", "iso-8859-1" );
	return $str;
}

sub win{
	Prima::message(decode "Tu as gagné");
}

sub min{
	my $min = shift;
	for(@_){
		$min = $_ if $min > $_;
	}
	$min;
}

sub adjustImage{
	my $button = shift;
	#~ my $img = $button->image;
	#~ say "Image: $img";
	#~ say "imageFile: ", $img->imageFile;
	my ($h,$w) = $button->image->size;
	my $scale = min( W_CARD / $w , H_CARD / $h);
	$button->imageScale( $scale );
}

sub card_timeout{
	if(@returned_cards == 2){
		for(@returned_cards){
			$_->set( imageFile => $face_card );
			adjustImage( $_ );
		}
		@returned_cards = ( );
	}
	$card_timer->stop;
}

sub card_clicked{ 
	my $self = shift;
	if(	@returned_cards == 2){
		#~ Prima::message( "Attend un peu!" );
		$card_timer->stop;
		card_timeout();
		#~ return;
	}
	if(	$self->imageFile ne $face_card){
		Prima::message( decode "Tu l'a déjà retourné!" );
		return;
	}
	
	$self->imageFile( $self->{pict} );
	adjustImage( $self );
	push @returned_cards, $self;
	if(	@returned_cards == 2 ){
		if($returned_cards[0]->{pict} eq $returned_cards[1]->{pict}){
			$remaining_pairs --;
			@returned_cards = ();
			win unless $remaining_pairs;
			return;
		}
		$card_timer->start;
	}
	else{
		$card_timer->stop;
	}
	#~ Prima::message( $self->{pict} );
}

sub start {
	use Prima qw(Application Buttons);
	use File::Glob qw(bsd_glob);
	use Data::Dumper;
	use File::HomeDir;
	my $dist_data = File::HomeDir->my_dist_data('App-Game-Memory', {create => 1});
	$dist_data =~ s{\\}{/}g;
	my $width = X_CARDS * W_CARD;
	my $height = Y_CARDS * H_CARD;
	my $win = new Prima::MainWindow(
			text     => 'Memory',
			size     => [ $width , $height],
	);
	
	$card_timer = Prima::Timer->create(
		timeout => 4_000,
		onTick => \&card_timeout,
	);
	my $image_path = $dist_data . '/images';
	my $pictures = qr/\.(?:png|gif|bmp|jpe?g)$/i;
	my @faces_picts = grep{ /$pictures/ } bsd_glob( "$image_path/*.*" );
	die "No face pictures! Please install images in folder $image_path"
		unless @faces_picts;
	$face_card = $faces_picts[ int rand scalar @faces_picts ];
	say "Using card's faces: $face_card" if DEBUG;
	my $theme = '*';	#change by 'lune' or so on...
	#~ my $theme = 'islam';
	my @images = grep{ /$pictures/ } 
						 bsd_glob( "$image_path/$theme/*.*" );
	die "No images! Please install images in folder $image_path/$theme"
		unless @images;
	say Dumper( \@images ) if DEBUG;	
	#~ pickup 10 images
	say "must have ", (X_CARDS * Y_CARDS)/2, " unique picture" if DEBUG;
	my @range = 1..(X_CARDS * Y_CARDS /2);
	my @picts = map{ splice @images, int rand scalar(@images), 1 } @range;
	$remaining_pairs = scalar @picts;
	say "Have ", scalar(@picts), " picts: ", Dumper( \@picts ) if DEBUG;
	@picts = sort { rand(3)-1 } @picts, @picts;
	say "picts: ", Dumper \@picts if DEBUG;
	for my $x (0..X_CARDS - 1){
		for my $y (0..Y_CARDS - 1){
			my $card = $win -> insert( Button =>
				backColor => 0x000000,
				owner => 'Board',
				origin => [ W_CARD * $x, H_CARD * $y],
				name => "card_${x}_${y}",
				imageScale => 0.5,
				size => [ W_CARD, H_CARD],
				onClick => \&card_clicked,
				color => 0xffffff,
				text => '',
				transparent => 0,
				flat => 1,
				#~ growMode => gm::Center,
				imageFile => $face_card,
			);
			my $img = pop @picts;
			$card->{pict} = $img;
			adjustImage( $card );
			say "$x,$y => $img";
		}
	}
	 
	run Prima;
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Nicolas Georges, C<< <xlat at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-game-memory at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Game-Memory>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Game::Memory


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Game-Memory>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Game-Memory>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Game-Memory>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Game-Memory/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Nicolas Georges.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of App::Game::Memory

package main;
App::Game::Memory::start();
