#!/usr/bin/perl -w
use strict;
use warnings;
use JSON qw(from_json);

sub getlang {
	my $lang = shift();
	my %db;
	open(my $fh, "-|", "curl", "https://nodecore.mine.nu/trans/api/translations/nodecore/core/$lang/file/") or die($!);
	open(my $raw, ">", "src/$lang.txt") or die($!);
	my $id;
	while(<$fh>) {
		print $raw $_;
		m#^\s*msgid\s+"(.*)"\s*$# and $id = $1;
		m#^\s*(?:msgstr\s+)?"(.*)"\s*$# or next;
		my $str = $1;
		$str =~ m#\S# or next;
		$str =~ s#\\"#"#g;
		$db{$id} = $str;
	}
	close($fh);
	close($raw);
	return \%db;
}

sub savelang {
	my $lang = shift();
	my $en = shift();
	my %db = %{shift()};
	map { $en->{$_} and $db{$_} ne $_ or delete $db{$_} } keys %db;
	%db or return;
	open(my $fh, ">", "nc_api.$lang.tr") or die($!);
	print $fh "# textdomain: nc_api\n";
	print $fh map { "$_=$db{$_}\n" } sort keys %db;
	close($fh);
	warn("updated: $lang\n");
}

my $en = getlang("en");
for my $k ( keys %$en ) {
	$en->{$k} eq "[REMOVED]" and delete $en->{$k};
}

my %langdb;
my $page = "https://nodecore.mine.nu/trans/api/translations/?format=json";
while($page) {
	open(my $fh, "-|", "curl", $page) or die($!);
	my $json = from_json(do { local $/; <$fh> });
	close($fh);
	$page = $json->{next};
	for my $r ( @{$json->{results}} ) {
		$r->{component}->{slug} eq "core" or next;
		$r->{component}->{project}->{slug} eq "nodecore" or next;
		my $code = $r->{language}->{code};
		$code eq 'en' or $langdb{$code} = getlang($code);
	}
	for my $sub ( keys %langdb ) {
		my $gen = $sub;
		$gen =~ s#_\S+$## or next;
		$langdb{$gen} //= {};
		map { $langdb{$gen}{$_} //= $langdb{$sub}{$_} } keys %{$langdb{$sub}};
	}
	for my $sub ( keys %langdb ) {
		my $gen = $sub;
		$gen =~ s#_\S+$## or next;
		map { $langdb{$sub}{$_} //= $langdb{$gen}{$_} } keys %{$langdb{$sub}};
	}
	map { savelang($_, $en, $langdb{$_}) } keys %langdb;
}
