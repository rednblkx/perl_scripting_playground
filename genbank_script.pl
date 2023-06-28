 # perl script.pl x y (ex: 1000 2000).
use strict;
use warnings;

my $genbank = undef;

# Get the number range as command-line arguments

unless (@ARGV){
die "You haven't specified a command line argument!\n"
};
my ($lower_limit, $upper_limit) = @ARGV;
chomp ($lower_limit);
chomp ($upper_limit);

# print "Input the name of your GenBank file (.dat):\n";
# $genbank = <STDIN>;
# chomp ($genbank);
open(my $fh, '<', "Homo_sapiens.GRCh38.109.chromosome.19.dat")  or die " The Genbank file $genbank can't be opened! :$!\n";

# Initialize an empty array to store the ranges of captured lines
my @captured_ranges;

# Initialize a flag to track if the current line is part of a range
my $in_range = 0;

# Initialize an empty array to store the current range of captured lines
my @current_range;

# Function to extract the start and end numbers from a range
sub extract_range {
    my ($range) = @_;
    if ($range =~ /(\d+)\.\.(\d+)/) {
        return ($1, $2);
    }
    return ();
}

# Read the input file line by line
while (my $line = <$fh>) {
    chomp($line);  # Remove newline character from the line

    # Check if the line matches the pattern "gene 305573..306467" or "gene complement(281040..291403)"
    if ($line =~ /^\s*gene\s+(\d+)\.\.(\d+)/ || $line =~ /^\s*gene\s+complement\((\d+)\.\.(\d+)\)/) {
        my ($start, $end) = ($1, $2);

        # If the range falls within the specified limits, set the flag indicating we are now in a new range
        if ($start >= $lower_limit && $end <= $upper_limit) {
            $in_range = 1;
        } else {
            $in_range = 0;
            next;
        }

        # If we were already in a range, push the current range into the array of captured ranges
        if (@current_range) {
            # my $text = join "\n", @current_range;
            push @captured_ranges, [@current_range];
            @current_range = ();
        }
    }

    # Capture lines within the range
    if ($in_range) {
        push @current_range, $line;
    }
}

# Push the last range into the array of captured ranges
if (@current_range) {
    # my $text = join "\n", @current_range;
    push @captured_ranges, \@current_range;
}

# Close the input file
close($fh);


my @genes = ();

# Output all captured ranges
foreach my $range (@captured_ranges) {
my @data = ();
    foreach my $line (@$range) {
        if ($line =~ /^\s*gene\s+/ ) {
            $in_range = 1;
        }elsif($line =~ /^\s*CDS\s+(.*)/){
            my ($range_start, $range_end) = extract_range($1);
            $in_range = 1;
            # print $range_start, "..", $range_end, "\n";
        }elsif ($line =~ /^\s{5}\w+\s{8}/) {
            $in_range = 0;
        }

        # Capture lines within the range
        if ($in_range) {
            print $line, "\n";
        }
    }
    print "\n";
}
