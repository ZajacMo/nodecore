#!/usr/bin/perl -w
use strict;
use warnings;
use JSON qw(from_json);

sub curl {
	my @cmd = qw(curl -fsL);
	$ENV{NC_WEBLATE_TOKEN} and
	  push @cmd, "-H", "Authorization: Token $ENV{NC_WEBLATE_TOKEN}";
	push @cmd, @_;
	warn("@_\n");
	open(my $fh, "-|", @cmd) or die($!);
	return $fh;
}
sub getlang {
	my $lang = shift();
	my %db;
	my $fh = curl("https://hosted.weblate.org/api/translations/minetest/nodecore/$lang/file/");
	open(my $raw, ">", "src/$lang.txt") or die($!);
	my $id;
	while(<$fh>) {
		print $raw $_;
		m#^\s*msgid\s+"(.*)"\s*$# and $id = $1;
		m#^\s*(?:msgstr\s+)?"(.*)"\s*$# or next;
		my $str = $1;
		$str =~ m#\S# or next;
		$str =~ s#\\"#"#g;
		$db{$id} = ($db{$id} // "") . $str;
	}
	$id or -s "nc_api.$lang.tr" and die("download failed or blank");
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

my %langdb;
my $page = "https://hosted.weblate.org/api/components/minetest/nodecore/translations/?format=json";
while($page) {
	my $fh = curl($page);
	my $json = do { local $/; <$fh> };
	close($fh);
	$json = from_json($json);
	$page = $json->{next};
	for my $r ( @{$json->{results}} ) {
		my $code = $r->{language}->{code};
		$code eq 'en' or $langdb{$code} = getlang($code);
	}
	for my $sub ( sort keys %langdb ) {
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
