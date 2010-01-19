#!/usr/local/bin/perl
# 
# build_menu.pl
# 
# Author(s): Pablo Fischer (pfischer@cpan.org)
# Created: 01/19/2010 13:44:22 PST 13:44:22

use strict;
use warnings;
use YUI::Menu::Markup;
use YUI::Menu::Markup::YAML;
use Data::Dumper;

my $markup_yaml = YUI::Menu::Markup::YAML->new(
        filename => 'examples/menu_yaml.yaml');
my $markup = YUI::Menu::Markup->new(
        source_ref => $markup_yaml);
print $markup->generate();

