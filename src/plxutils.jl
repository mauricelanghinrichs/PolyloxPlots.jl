
function checkdf(df::DataFrame)
    first(propertynames(df))==:Barcode || error("Expected dataframe column name Barcode (first column)")
    "Barcode" in String.(names(df)[firstindex(names(df))+1:end]) && error("Unexpected dataframe column name Barcode")
    "Sum" in String.(names(df)) && error("Reserved dataframe column name Sum")
    "Fate" in String.(names(df)) && error("Reserved dataframe column name Fate")
    
end