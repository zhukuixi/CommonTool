![Page0](https://github.com/zhukuixi/CommonTool/blob/master/HGNC_IDmapper/img/HGNC.png)

Currently, it supports ID mapping between all the columns appear in the HGNC_2020.txt file.   
### Basic Mapping
On default setting, you can do mapping between "symbol","entrez","ensemble" and "uniport".

### Custom Mapping
As it is already mentioned in the code, you could also specify which column you want to "match from" and "match to" by typing the specific column names. Thus, besides ID mapping, you might also get some useful information like Enzyme, Chromosome.

### About Mapped from Symbol
If you mapped from symbol, the code would search "Approved symbol" first. If it failed to get any results, it will use the helper file (aliasPreviousSymbol_ind.txt) to search the "Previous symbols" and "Alias symbols".  Thus, it could generate more than one mapped IDs. For all the other input ID type, it would only generate one mapped ID for each input ID.
         