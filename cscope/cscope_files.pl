use File::Find;
#use 5.010;
$path=$ARGV[0];
$path_cs=$ARGV[1];
$what_do=$ARGV[2];#1.cscope,2.lookupfile,3,all
$is_cscope=0;
$is_lookupfile=0;
$is_all=0;
if ($what_do eq 'cscope') {
	$is_cscope=1;
}
elsif($what_do eq 'lookupfile') {
	$is_lookupfile=1;
}
elsif($what_do eq 'all') {
	$is_all=1;
	$is_cscope=1;
	$is_lookupfile=1;
}
chomp $path;
$path=~s/(.*)[\/|\\].*/$1/;

if($is_cscope==1){
	if($^O=~/win32/i)#gen a bat for cscope.os-win32
	{
		chomp $path_cs;
		$path_cs=$path_cs.'/cscope/';
		$cs_gen_name='cs_gen.bat';
		$cs_gen_con='PATH='.$path_cs.
		'
		del cscope.in.out
		del cscope.out
		del cscope.po.out
		del ncscope.in.out
		del ncscope.out
		del ncscope.po.out
		cscope -Rbqk
		';
		open CS_HAND,'>',$cs_gen_name;
		print CS_HAND $cs_gen_con;
		close CS_HAND;

	}
}

$option{wanted}=\&gen_list;
$option{preprocess}=\&fliter;
my(@list_all,@list_cs,@list_lookup)=undef;#store the list in memory
find(\%option,$path);#gen the @list_all
&main($path);

sub main{
	my $path=@_[0];
	chomp $path;

	&gen_cscope_files($path,\@list_all,\@list_cs);
	&gen_lookup_files($path,\@list_all,\@list_lookup);
}

sub gen_lookup_files
{
	my ($path,$ref_all,$ref_lookup)=@_;
	my $lookup_file=$path."\/filenametags";

	print "look file is:".$lookup_file."\n";
	open HAND_LOOKUP,'>',$lookup_file or die $!;
	print HAND_LOOKUP "!_TAG_FILE_SORTED\t2\t/2=foldcase/" or die $!;#head
	#print "ref_lookup is @{$ref_lookup}[0..10] \n";
	@{$ref_lookup}=map{
	$item=$_;
	my($name,$path)=split /\t/,$_;
	if(1==&is_lookup($name))
	{
		$item;
	}
	else{
		undef;
	}
	}@{$ref_all};

	@{$ref_lookup}=sort @{$ref_lookup};
	foreach my $item (@{$ref_lookup}) {
		print HAND_LOOKUP $item."\t1\n" or die $!;
	}
	close HAND_LOOKUP;
}
sub gen_cscope_files
{
	my ($path,$ref_all,$ref_cs)=@_;
	#my @all=@{$ref_all};
	my $cs_file=$path."\/cscope\.files";
	open HAND,'>',$cs_file or die $!;
	foreach my $item (@{$ref_all}) {
		my($name,$path)=split /\t/,$item;
		if(1==&is_cscope($name)){
			push @{$ref_cs},$path;
		}
	}
	foreach my $item (@{$ref_cs}) {
		print HAND $item."\n" or die $!;
	}
	close HAND;


}
sub gen_list{
	next if $_ eq '.';
	next if $_ eq '..';
	next if -d $_;
	next if (/\W$/);# like ".h~"
	my $is_code=&is_code($_);	
	if (
		1==$is_code
		||/\.xml$/i
		||/\.txt$/i
		||/\.ini$/i
		||/\.bld$/i
		||/^\w+$/i
	) {
		$item=$_."\t".$File::Find::name;
		push @list_all,$item;
	}
}
sub fliter{
	@arr=grep{
	$_!~/^build$/i
	}@_;

	@arr=grep{
	$_!~/^\.\w+$/
	}@arr;

	@arr=grep{
	$_!~/^classes$/i
	}@arr;

	@arr=grep{
	$_!~/^cscope\./i
	}@arr;

	@arr=grep{
	$_!~/^__pro__$/i
	}@arr;

	@arr=grep{
	$_!~/^_pro_$/i
	}@arr;

	@arr=grep{
	$_!~/^out$/i
	}@arr;

	@arr;
# grep{/\.pl$/||-d}@_;
#@_;
}
sub is_code {

	$_=$file=@_[0];
	return 1 if (
		/\.h$/i
		||/\.c$/i
		||/\.cpp$/i
		||/\.java$/i
		||/\.s$/i
		||/\.asm$/i
		||/\.masm$/i
		||/\.pl$/i
		||/\.mak$/i
		||/\.mk$/i
		||/\.py$/i
	);
	0;
}
sub is_cscope {
	my $_=@_[0];
	return 0 if ( $_ eq 'tags');
	return 0 if ( $_ eq 'filenametags');
	my $is_code=&is_code($_);	
	return 1 if (1==$is_code);
	return 1 if (
		/\.xml$/i
		||/\.ini$/i
		||/\.bld$/i
		||/^\w+$/i
	);
	0;
}
sub is_lookup{

	my $file=@_[0];

	my $is_code=&is_code($file);	
	return 1 if (1==$is_code);
	$_=$file;
	return 1 if (
		/\.xml$/i
		||/\.txt$/i
		||/\.ini$/i
		||/\.bld$/i
		||/^\w+$/i
	);
	0;
}
