module freetype.freetype;

public import freetype.types;

extern(C) nothrow
{
    FT_Error FT_Init_FreeType(FT_Library*);
    FT_Error FT_New_Face(FT_Library, const(char)*, FT_Long, FT_Face*);
    FT_Error FT_Set_Pixel_Sizes(FT_Face, FT_UInt, FT_UInt);
    FT_Error FT_Load_Char(FT_Face, FT_ULong, FT_Int32);
}
