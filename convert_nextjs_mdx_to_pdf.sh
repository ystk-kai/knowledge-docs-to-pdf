#!/bin/bash

# 一時ディレクトリを作成
export temp_output_dir=$(mktemp -d)
export temp_repo_dir=$(mktemp -d)

echo "Temp output directory: $temp_output_dir"
echo "Temp repo directory: $temp_repo_dir"

# Set the OSFONTDIR environment variable
export OSFONTDIR="/usr/share/fonts:/usr/local/share/fonts:~/.fonts"

# Set the branch or tag to clone (default is 'canary')
export BRANCH_OR_TAG=${BRANCH_OR_TAG:-canary}
export OUTPUT_DIR=${OUTPUT_DIR:-/app/dist}

mkdir -p "$OUTPUT_DIR"

echo "Branch or tag: $BRANCH_OR_TAG"
echo "Output directory: $OUTPUT_DIR"

# Clone the specified branch or tag from the repository into the temporary directory
git clone --branch $BRANCH_OR_TAG --depth 1 https://github.com/vercel/next.js.git $temp_repo_dir

export input_dir="$temp_repo_dir/docs"  # MDXファイルがあるディレクトリへのパス
export output_pdf="$OUTPUT_DIR/nextjs_docs.pdf"  # 結合されたPDFファイルの出力先

echo "Input directory: $input_dir"
echo "Output PDF: $output_pdf"

# 出力PDFファイルをクリア
> "$output_pdf"

# MDXファイルをPDFに変換して結合
export file_count=$(find "$input_dir" -type f -name "*.mdx" | wc -l)
export current_file=0

echo "Total files to process: $file_count"

convert_mdx_to_pdf() {
  mdx_file=$1
  job_number=$2
  echo "MDX file: $mdx_file"
  echo "Processing job number: $job_number, file: $mdx_file"
  pdf_file="$temp_output_dir/$(basename "$mdx_file" .mdx).pdf"
  pandoc -f markdown "$mdx_file" -o "$pdf_file" --pdf-engine=xelatex \
    --variable mainfont="Noto Sans" \
    --variable sansfont="Noto Sans" \
    --variable monofont="Noto Sans Mono"
  echo -e "\tGenerated PDF: $pdf_file"
}

export -f convert_mdx_to_pdf

find "$input_dir" -type f -name "*.mdx" | parallel convert_mdx_to_pdf {} {#}

# Check if any PDF files exist in the temp directory
if [ $(ls "$temp_output_dir"/*.pdf 2> /dev/null | wc -l) -eq 0 ]; then
  echo "No PDF files found in the temp directory"
  exit 1
fi

# 一時PDFファイルを結合
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$output_pdf" "$temp_output_dir"/*.pdf

# 一時ディレクトリをクリーンアップ
rm -rf "$temp_output_dir"

echo "Conversion completed. Output PDF: $output_pdf"
