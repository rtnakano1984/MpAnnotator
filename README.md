# README for MpAnnotator

This is an R script to insert gene annitation information to the list of gene IDs.  
- Gene IDs need to be listed in a text file (\*.txt).  
- Gene IDs should be in the v5.1 format. Those in v3.1, or the mixture of v5.1 and v3.1 are not accepted.  
- The input file should only contain one column (gene IDs) _**without a header row**_.  
- Gene IDs can be concatenated with ";", as in the case of a Mass Spec result table.
- Reference data should be stored at: `/biodata/dep_psl/common/MpAnnotator/data`. Alternatively, you can download and stored them in your local directory. In that case, the respective line in the script needs to be modified.

-----

There are three different types of output, concerning concatenated IDs:
1. **"Simplified": Reference information for the first gene ID among those concatenated will be used.**  
   - This can be the simplest but loose information for the other genes.  

2. **"Concatenated": Reference information for all concatenated gene IDs will be concatenated into one raws.**
   - This contains all information and compatible with the original gene list (the same row number), but hard to read.  

3. **"Full": Each concatenated gene IDs will have multiple rows, each of which contains the refernece information for each gene.**
   - This contains all information and easy to read but cannot be merged with the original ID list.

0. **Export all three types of outputs.**



-----


### Usage:
```
Rscript MpAnnotator.R [input] [output type]
```

`[input]` should be the path to your input file. The result file(s) will be exported to the same directory as the input file.
`[output type]` should one of 1, 2, 3, and 0, corresponding to the output types (see above). Default: 0.


-----

### Requirement:
##### R software (https://www.r-project.org/)
##### R package "stringr"
