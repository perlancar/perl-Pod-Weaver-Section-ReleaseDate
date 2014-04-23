package Pod::Weaver::Section::ReleaseDate;

use 5.010001;
use Moose;
#use Text::Wrap ();
with 'Pod::Weaver::Role::Section';

#use Log::Any '$log';

use Moose::Autobox;

# VERSION

sub weave_section {
    my ($self, $document, $input) = @_;

    # check file
    unless ($filename =~ m!^(lib|bin|scripts?)/(.+)\.(pm|pl|pod)$!) {
        $self->log_debug(["skipped file %s (not a Perl module/script/POD)",
                          $filename]);
        return;
    }

    # extract date from file
    my $date;
    {
        # XXX does podweaver already provide file content?
        open my($fh), "<", $filename or die "Can't open file $filename: $!";

        local $/;
        my $content = <$fh>;

        $content =~ /^\s*our \$DATE = '([^']+)'/m or last;
        $date = $1;
    }
    unless (defined $date) {
        $self->log_debug(["skipped file %s (no release date defined)",
                          $filename]);
        return;
    }

    # insert POD section
    $document->children->push(
        Pod::Elemental::Element::Nested->new({
            command  => 'head1',
            content  => 'RELEASE DATE',
            children => [
                Pod::Elemental::Element::Pod5::Ordinary->new({ content => $date }),
            ],
        }),
    );
}

no Moose;
1;
# ABSTRACT: Add a RELEASE DATE section (from package's $DATE)

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your C<weaver.ini>:

 [ReleaseDate]


=head1 DESCRIPTION

This section plugin adds a RELEASE DATE section to Perl modules/scripts. Release
date is taken from module's C<$DATE> package variable (extracted using regexp).
If the variable is not defined, the section is not added.


=head1

=head1 SEE ALSO

L<Pod::Weaver::Section::Version>

=cut
