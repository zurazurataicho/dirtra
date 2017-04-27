use strict;
use warnings;
use Class::Struct;

struct Tree => {
    name => '$',
    depth => '$',
    child => '@',
    count => '$'
};
our $tcnt;
our @dtree = ();

&main;

sub dirtra {
    my($dirname, $depth) = @_;
    opendir my $hdir, $dirname or die "Failed to open $dirname: $!";
    $depth++;
    while (my @dir = readdir($hdir)) {
        my $child_cnt = 0;
        my $orig_tcnt = $tcnt;
        foreach (@dir) {
            my $path = $dirname . "/" . $_;
            next if (/^\..*$/);
            next if (-f $path);
            $tcnt++;
            $dtree[$tcnt] = new Tree();
            $dtree[$tcnt]->name($_);
            $dtree[$tcnt]->depth($depth);
            $dtree[$orig_tcnt]->child($child_cnt++, $tcnt);
            &dirtra($path, $depth);
        }
        $dtree[$orig_tcnt]->count($child_cnt);
    }
    closedir $hdir;
}

sub show {
    my($entry) = @_;
    print '  ' x $dtree[$entry]->depth . '+-';
    print $dtree[$entry]->name . " [entry=$entry/depth=" . $dtree[$entry]->depth() . "]\n";
    return if (!$dtree[$entry]->count);
    for (my $i = 0; $i < $dtree[$entry]->count; $i++) {
        &show($dtree[$entry]->child($i));
    }
}

sub init {
    $tcnt = 0;
    $dtree[$tcnt] = new Tree(
            depth => 0,
            name => '.',
            count => 0
        );
}

sub main {
    &init();
    &dirtra("/PATH/TO/PLEASE/CHANGE/YOUR/OWN", 0);
    &show(0);
}
