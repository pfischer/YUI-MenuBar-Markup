#
# YUI::Menu::Markup
#
# Author(s): Pablo Fischer (pfischer@cpan.org)
# Created: 01/19/2010 10:05:38 PST 10:05:38
package YUI::Menu::Markup;

=head1 NAME

YUI::Menu::Markup - Generate YUI markup menus

=head1 DESCRIPTION

YUI::Menu::Markup will help you create your YUI menus by using markup (html).

It offers a very light interface to create your modules from any kind of data,
like I<perl raw> (hashes) to even L<YAML>.

There are no plans in giving support for creating YUI menus by javascript data.
Even, the html genearated doesn't allow modifications such as changing the CSS
class name of the items.

=cut
use Mouse;
use IO::Scalar;

=head1 Attributes

=over 4

=item B<source_class>

If you have your own class (or module) for getting the data of the menu please
use this attribute. It should be the module name (I<Foo::Bar>) and have the
module should have a I<new()> method.

If your module doesn't have anything of the above please take a look to
L<source_ref>.

=cut
has 'source_class' => (
        is => 'rw',
        isa => 'Str');

=item B<source_ref>

Similar to L<source_class> but it should be the reference (eg, the object) to
the source.

The class contained in this refernece should have a method named L<get_source>
and should return an array of hashes to be used for building the menu.

=cut
has 'source_ref' => (
        is => 'rw',
        isa => 'Ref');

=item B<data>

The data that will be used for building the menu, should be an array of hashes
where

=back 

=cut
has 'data' => (
        is => 'rw',
        isa => 'ArrayRef');

=head1 Methods

=head2 B<generate()>

Builds the HTML and javascript caller for the menu and returns it as a string

=cut
sub generate {
    my ($self) = @_;

    if (defined $self->{'source'}) {
        my $sref = "$self->{'source'}"->new();
        if ($sref->can('get_data')) {
            $self->{'data'} = $sref->get_data();
        } else {
            warn "$self->{'source'} does not have a get_data() method";
        }
    } elsif (defined $self->{'source_ref'}) {
        if ($self->{'source_ref'}->can('get_data')) {
            $self->{'data'} = $self->{'source_ref'}->get_data();
        }
    }

    if ($self->{'data'}) {
        my $html;
        $html .= "<div id=\"" . $self->_get_id() . "\" class=\"yuimenubar yuimenubarnav\">\n";
        $html .=  "<div class=\"bd\">\n";
        $html .= $self->_generate_child_menu(
                $self->{'data'},
                1);
        $html .=  "</div>\n";
        $html .=  "</div>\n";
        return $html;
    }
}

############################## PRIVATE METHODS #################################
# Builds the <ul>, <li> and <div> for the menus and submenus
sub _generate_child_menu {
    my ($self, $menu, $level) = @_;

    my $tab = "\t" x $level;
    my $html = "";
    $html .=  "$tab<ul class=\"first-of-type\">\n";
    my $is_first = 1;
    foreach my $item (@{$menu}) {
        if (defined $item->{'name'}) {
            my $extra_class = '';
            if (defined $item->{'classes'}) {
                $extra_class = $item->{'classes'};
            }
            if ($is_first) {
                if ($extra_class) {
                    $extra_class = "$extra_class first-of-type";
                }
                $is_first = 0;
            }
            my $link = '#';
            if (defined $item->{'link'}) {
                $link = $item->{'link'};
            }
            $html .=  "$tab<li class=\"yuimenubaritem $extra_class\">";
            $html .=  "<a class=\"yuimenubaritemlabel\" href=\"$link\">";
            $html .=  $item->{'name'} . "</a>";
            if (defined $item->{'menu'}) {
                $html .= "\n";
                my $id = (defined $item->{'id'}) ?
                    $item->{'id'} :
                    $self->_generate_random_id();
                $html .= "$tab<div id=\"$id\">\n";
                $html .= "$tab<div class=\"bd\">\n";
                $html .= $self->_generate_child_menu(
                        $item->{'menu'},
                        $level+1);
                $html .= "$tab</div>\n";
                $html .= "$tab</div>\n";
                $html .=  "$tab</li>\n";
            } else {
                $html .= "</li>\n";
            }
        }
    }
    $html .=  "$tab</ul>\n";
    return $html;
}

# Generates a random ID
sub _generate_random_id {
    my ($self) = @_;

    return 'rand_yui_menu_markup_id' . int(rand(100));
}

# Gets the ID of the complete menu, the top ID. If no ID is set then a random
# ID is returned
sub _get_id {
    my ($self) = @_;

    if (defined $self->{'top_id'}) {
        return $self->{'top_id'};
    }
    return $self->_generate_random_id();

}

1;

