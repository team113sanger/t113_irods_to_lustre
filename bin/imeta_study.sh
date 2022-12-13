#!/usr/bin/env bash
# to expand errors during the piping process 
set -e
set -o pipefail


# Set constants
study_id=$1
outfile="${study_id}_samples.tsv"
baton_path="/software/sciops/pkgg/baton/2.0.1+1da6bc5bd75b49a2f27d449afeb659cf6ec1b513/bin"
zone="seq"

# Set an array of fields we want to return
# These may differ by study so will need revising
declare -A fields=(	
	['id_run']='____\($a.avus | .[] | select(.attribute == "id_run") | .value)'
	['tag_index']='____\($a.avus | .[] | select(.attribute == "tag_index") | .value)'
	['total_reads']='____\($a.avus | .[] | select(.attribute == "total_reads") | .value)'
	['is_paired_read']='____\($a.avus | .[] | select(.attribute == "is_paired_read") | .value)'
	['md5']='____\($a.avus | .[] | select(.attribute == "md5") | .value)'
	['alignment']='____\($a.avus | .[] | select(.attribute == "alignment") | .value)'
	['sample_supplier_name']='____\($a.avus | .[] | select(.attribute == "sample_supplier_name") | .value)'
	['study_id']='____\($a.avus | .[] | select(.attribute == "study_id") | .value)'
	['study']='____\($a.avus | .[] | select(.attribute == "study") | .value)'
)

# Bail out gracefully if no study_id is provided
if [ -z "$1" ]
  then
    echo "ERROR: no study_id was provided."
	 exit 1;
fi

# Set output filename, if it exists, warn and remove it
if [ -f "$outfile" ]; then
    echo "WARNING: removing existing samplesheet: ${outfile}";
	 rm -f 
fi

# Build and write samplesheet header
samplesheet_header='sample\tfile'
for field in "${!fields[@]}"
do
	samplesheet_header="${samplesheet_header}\t${field}"
done
samplesheet_header="${samplesheet_header}\n"
printf "${samplesheet_header}" > "${outfile}"

# Check samplesheet exists 
if [ ! -f "${outfile}" ] 
then
	echo "ERROR: problem creating samplesheet: ${outfile}"
	exit 1
fi

# Check samplesheet isn't empty
if [[ 0 = $(wc -l "${outfile}") ]]
then
	echo "ERROR: samplesheet is empty: ${outfile}"
	exit 1
fi

# Build query from array of fields
metaquery='.[] as $a | "\($a.avus | .[] | select(.attribute == "sample") | .value)____\($a.collection)/\($a.data_object)'
for field in "${!fields[@]}"
do
	metaquery="${metaquery}${fields[${field}]}"
done
metaquery="${metaquery}"'"'

# The speed of this query is dependent on the order of the attributes 
# Removed manual_qc attribute as (for now) we want all samples irrespective of QC status
echo "Getting sample metadata from iRODS..."
jq --arg study_id $study_id -n '{avus: [
	{attribute: "study_id", value: $study_id, o: "="},
	{attribute: "type", value: ["cram"], o: "in"}, 
	{attribute: "target", value: "1", o: "="}]}' |\
"${baton_path}/baton-metaquery" \
	--zone "${zone}" --obj --avu |\
jq "${metaquery}" |\
	sed s"/$(printf '\t')//"g |\
	sed s"/\"//"g |\
	sed s"/____/$(printf '\t')/"g |\
sort | uniq >> "${outfile}"
echo "Processing sample metadata..."

# Get number of samples
sample_num=$(awk 'NR > 1 {print $1}' ${outfile} | uniq | wc -l)
echo "Number of samples: ${sample_num}"

# Get number of files
file_num=$(awk 'NR > 1'  ${outfile} | wc -l)
echo "Number of files: ${file_num}"

# Check samplesheet contains more than one line (i.e. we have samples)
if [[ 0 == $sample_num ]]
then
	echo "ERROR: no samples in samplesheet: ${outfile}";
	exit 1;
fi

echo "DONE"
exit 0;
