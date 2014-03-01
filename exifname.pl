use Cwd;
use Image::ExifTool;
my $exifTool = new Image::ExifTool;
$exifTool->Options(Unknown => 2);

my $some_dir = $ARGV[0] || getcwd;

print $some_dir."\n";
chdir $some_dir;

opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
    	@images = grep { /JPG/i } readdir(DIR);
	print "@images\n";
closedir DIR;
foreach $file (@images) {
	($deYv,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
		$atime,$mtime,$ctime,$blksize,$blocks)
	= stat($file);
print    "$deYv,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks\n";
# print    '$deYv,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks';
# 	$mtime-=3560;
#	$mtime+=58*60+20;
	# utime $atime, $mtime, $file;
	$info = $exifTool->ImageInfo($file,"CreateDate");
   foreach (sort keys %$info) {
	 print "$_ => $$info{$_} \n";
    }
	$fname = $$info{"CreateDate"};
	$fname =~ s/ +/_/g;
	$fname =~ s/:/_/g;
	print "$file, $fname.jpg \n";
	rename $file, $fname."_".$file;

}
sleep 2;
exit;
