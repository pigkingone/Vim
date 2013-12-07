#!usr/bin/perl

use File::Find;
#use 5.010;
$path=$ARGV[0];
chomp $path;
$path=~s/(.*)[\/|\\].*/$1/;

if($^O=~/win32/i)
{
	$path_cs=$ARGV[1];
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

&main($path);

sub main{
	my $path=@_[0];
	chomp $path;
	my $cs_file;
	$cs_file=$path."\/cscope\.files";
if($^O=~/win32/i)
{
	open HAND,'>','cscope.files' or die $!;
}
else
{
	open HAND,'>',$cs_file or die $!;
}


#add for lookupfile.vim,named filename.tags
my $lookup_files;
$lookup_files=$path.'/filenametags';
if($^O=~/win32/i)
{
	open HAND_LOOKUP_FILES,'>','filenametags' or die $!;
}
else
{
	open HAND_LOOKUP_FILES,'>',$lookup_files or die $!;
}
print HAND_LOOKUP_FILES '!_TAG_FILE_SORTED	2	/0=unsorted, 1=sorted, 2=foldcase/'."\n";
	$option{wanted}=\&gen_list;
	$option{preprocess}=\&fliter;
	find(\%option,$path);
}
sub gen_list{
	next if $_ eq '.';
	next if $_ eq '..';
	next if -d $_;
	next if (/\W$/);# like ".h~"
	#next if (/\.\w$/);# like ".h~"
	next if ( $_ eq 'tags');
	next if ( $_ eq 'filenametags');
	if (									#cscope
		/\.h$/i
		||/\.c$/i
		||/\.cpp$/i
		||/\.java$/i
		||/\.pl$/i
		||/\.mak$/i
		||/\.mk$/i
		||/\.xml$/i
		||/\.txt$/i
		||/\.py$/i
		||/^\w+$/i
	) {
		print HAND $File::Find::name."\n" if !-d $File::Find::name;
		print HAND_LOOKUP_FILES $_."\t".$File::Find::name."\t1\n" if !-d $File::Find::name;
	}
	elsif(									#lookupfiles
		/\.ini$/i
		||/\.bld$/i
	)
	{
		print HAND_LOOKUP_FILES $_."\t".$File::Find::name."\t1\n" if !-d $File::Find::name;
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
close HAND;
close HAND_LOOKUP_FILES;
