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
	$option{wanted}=\&gen_list;
	$option{preprocess}=\&fliter;
	find(\%option,$path);
}
sub gen_list{
	next if $_ eq '.';
	next if $_ eq '..';
	next if -d $_;
	next if (
			/\.so$/i
			||/\.a$/i
			||/\.bin$/i
			||/\.elf$/i
			||/\.txt$/i
			||/\.dll$/i
			||/\.lib$/i
			||/\.ttf$/i
			||/\.text$/i
			||/\.dex$/i
			||/\.dpk$/i
			||/\.class$/i
			||/\.pdf$/i
			||/\.png$/i
			||/\.bmp$/i
			||/\.gif$/i
			||/\.swp$/i
			||/\.bak$/i
			||/\.db$/i
			||/~$/i
	);
#	next if !(/\.h$/i
#		|| /\.c$/i
#		|| /\.cpp$/i
#		|| /\.mak$/i
#		|| /\.res$/i
#		|| /\.bat$/i
#		|| /\.pl$/i);
	print HAND $File::Find::name."\n" if !-d $_;
}
sub fliter{
	@arr=grep{
		$_!~/^build$/
	}@_;
	@arr=grep{
		$_!~/^\.repo$/
	}@arr;
	@arr=grep{
		$_!~/^\.git$/
	}@arr;
	@arr=grep{
		$_!~/^\.svn$/
	}@arr;
	@arr=grep{
		$_!~/^classes$/
	}@arr;
	@arr=grep{
		$_!~/^cscope\./
	}@arr;
	@arr=grep{
		$_!~/^__pro__$/
	}@arr;
	@arr=grep{
		$_!~/^out$/i
	}@arr;
	@arr;
# grep{/\.pl$/||-d}@_;
#@_;
}
close HAND;
