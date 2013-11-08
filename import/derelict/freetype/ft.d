/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.freetype.ft;

public {
    import derelict.freetype.types;
    import derelict.freetype.functions;
}

private {
    import derelict.util.loader;
    import derelict.util.system;

    static if(Derelict_OS_Windows)
        enum libNames = "dll/freetype.dll,dll/libfreetype-6.dll";
    else static if(Derelict_OS_Mac)
        enum libNames = "libfreetype.dylib,libfreetype.6.dylib,libfreetype.6.3.16.dylib,/usr/X11/lib/libfreetype.dylib,/usr/X11/lib/libfreetype.6.dylib,/usr/X11/lib/libfreetype.6.3.16.dylib";
    else static if(Derelict_OS_Posix)
        enum libNames = "libfreetype.so.6,libfreetype.so";
    else
        static assert(0, "Need to implement FreeType libNames for this operating system.");
}

class DerelictFTLoader : SharedLibLoader {
    public this() {
        super(libNames);
    }

    protected override void loadSymbols() {
        bindFunc(cast(void**)&FT_Init_FreeType, "FT_Init_FreeType");
        bindFunc(cast(void**)&FT_Done_FreeType, "FT_Done_FreeType");
        bindFunc(cast(void**)&FT_New_Face, "FT_New_Face");
        bindFunc(cast(void**)&FT_New_Memory_Face, "FT_New_Memory_Face");
        bindFunc(cast(void**)&FT_Open_Face, "FT_Open_Face");
        bindFunc(cast(void**)&FT_Attach_File, "FT_Attach_File");
        bindFunc(cast(void**)&FT_Attach_Stream, "FT_Attach_Stream");
        bindFunc(cast(void**)&FT_Reference_Face, "FT_Reference_Face");
        bindFunc(cast(void**)&FT_Done_Face, "FT_Done_Face");
        bindFunc(cast(void**)&FT_Select_Size, "FT_Select_Size");
        bindFunc(cast(void**)&FT_Request_Size, "FT_Request_Size");
        bindFunc(cast(void**)&FT_Set_Char_Size, "FT_Set_Char_Size");
        bindFunc(cast(void**)&FT_Set_Pixel_Sizes, "FT_Set_Pixel_Sizes");
        bindFunc(cast(void**)&FT_Load_Glyph, "FT_Load_Glyph");
        bindFunc(cast(void**)&FT_Load_Char, "FT_Load_Char");
        bindFunc(cast(void**)&FT_Set_Transform, "FT_Set_Transform");
        bindFunc(cast(void**)&FT_Render_Glyph, "FT_Render_Glyph");
        bindFunc(cast(void**)&FT_Get_Kerning, "FT_Get_Kerning");
        bindFunc(cast(void**)&FT_Get_Track_Kerning, "FT_Get_Track_Kerning");
        bindFunc(cast(void**)&FT_Get_Glyph_Name, "FT_Get_Glyph_Name");
        bindFunc(cast(void**)&FT_Get_Postscript_Name, "FT_Get_Postscript_Name");
        bindFunc(cast(void**)&FT_Select_Charmap, "FT_Select_Charmap");
        bindFunc(cast(void**)&FT_Set_Charmap, "FT_Set_Charmap");
        bindFunc(cast(void**)&FT_Get_Charmap_Index, "FT_Get_Charmap_Index");
        bindFunc(cast(void**)&FT_Get_Char_Index, "FT_Get_Char_Index");
        bindFunc(cast(void**)&FT_Get_First_Char, "FT_Get_First_Char");
        bindFunc(cast(void**)&FT_Get_Next_Char, "FT_Get_Next_Char");
        bindFunc(cast(void**)&FT_Get_Name_Index, "FT_Get_Name_Index");
        bindFunc(cast(void**)&FT_MulDiv, "FT_MulDiv");
        bindFunc(cast(void**)&FT_MulFix, "FT_MulFix");
        bindFunc(cast(void**)&FT_DivFix, "FT_DivFix");
        bindFunc(cast(void**)&FT_RoundFix, "FT_RoundFix");
        bindFunc(cast(void**)&FT_CeilFix, "FT_CeilFix");
        bindFunc(cast(void**)&FT_FloorFix, "FT_FloorFix");
        bindFunc(cast(void**)&FT_Vector_Transform, "FT_Vector_Transform");
        bindFunc(cast(void**)&FT_Library_Version, "FT_Library_Version");
        bindFunc(cast(void**)&FT_Face_CheckTrueTypePatents, "FT_Face_CheckTrueTypePatents");
        bindFunc(cast(void**)&FT_Face_SetUnpatentedHinting, "FT_Face_SetUnpatentedHinting");
        bindFunc(cast(void**)&FT_List_Find, "FT_List_Find");
        bindFunc(cast(void**)&FT_List_Add, "FT_List_Add");
        bindFunc(cast(void**)&FT_List_Insert, "FT_List_Insert");
        bindFunc(cast(void**)&FT_List_Remove, "FT_List_Remove");
        bindFunc(cast(void**)&FT_List_Up, "FT_List_Up");
        bindFunc(cast(void**)&FT_List_Iterate, "FT_List_Iterate");
        bindFunc(cast(void**)&FT_List_Finalize, "FT_List_Finalize");
        bindFunc(cast(void**)&FT_Outline_Decompose, "FT_Outline_Decompose");
        bindFunc(cast(void**)&FT_Outline_New, "FT_Outline_New");
        bindFunc(cast(void**)&FT_Outline_New_Internal, "FT_Outline_New_Internal");
        bindFunc(cast(void**)&FT_Outline_Done, "FT_Outline_Done");
        bindFunc(cast(void**)&FT_Outline_Done_Internal, "FT_Outline_Done_Internal");
        bindFunc(cast(void**)&FT_Outline_Check, "FT_Outline_Check");
        bindFunc(cast(void**)&FT_Outline_Get_CBox, "FT_Outline_Get_CBox");
        bindFunc(cast(void**)&FT_Outline_Translate, "FT_Outline_Translate");
        bindFunc(cast(void**)&FT_Outline_Copy, "FT_Outline_Copy");
        bindFunc(cast(void**)&FT_Outline_Transform, "FT_Outline_Transform");
        bindFunc(cast(void**)&FT_Outline_Embolden, "FT_Outline_Embolden");
        bindFunc(cast(void**)&FT_Outline_Reverse, "FT_Outline_Reverse");
        bindFunc(cast(void**)&FT_Outline_Get_Bitmap, "FT_Outline_Get_Bitmap");
        bindFunc(cast(void**)&FT_Outline_Render, "FT_Outline_Render");
        bindFunc(cast(void**)&FT_Outline_Get_Orientation, "FT_Outline_Get_Orientation");
        bindFunc(cast(void**)&FT_New_Size, "FT_New_Size");
        bindFunc(cast(void**)&FT_Done_Size, "FT_Done_Size");
        bindFunc(cast(void**)&FT_Activate_Size, "FT_Activate_Size");
        bindFunc(cast(void**)&FT_Add_Module, "FT_Add_Module");
        bindFunc(cast(void**)&FT_Get_Module, "FT_Get_Module");
        bindFunc(cast(void**)&FT_Remove_Module, "FT_Remove_Module");
        bindFunc(cast(void**)&FT_Reference_Library, "FT_Reference_Library");
        bindFunc(cast(void**)&FT_New_Library, "FT_New_Library");
        bindFunc(cast(void**)&FT_Done_Library, "FT_Done_Library");
        bindFunc(cast(void**)&FT_Set_Debug_Hook, "FT_Set_Debug_Hook");
        bindFunc(cast(void**)&FT_Add_Default_Modules, "FT_Add_Default_Modules");
        bindFunc(cast(void**)&FT_Get_TrueType_Engine_Type, "FT_Get_TrueType_Engine_Type");
        bindFunc(cast(void**)&FT_Get_Renderer, "FT_Get_Renderer");
        bindFunc(cast(void**)&FT_Set_Renderer, "FT_Set_Renderer");
        bindFunc(cast(void**)&FT_Has_PS_Glyph_Names, "FT_Has_PS_Glyph_Names");
        bindFunc(cast(void**)&FT_Get_PS_Font_Info, "FT_Get_PS_Font_Info");
        bindFunc(cast(void**)&FT_Get_PS_Font_Private, "FT_Get_PS_Font_Private");
        bindFunc(cast(void**)&FT_Get_PS_Font_Value, "FT_Get_PS_Font_Value");
        bindFunc(cast(void**)&FT_Get_Sfnt_Table, "FT_Get_Sfnt_Table");
        bindFunc(cast(void**)&FT_Load_Sfnt_Table, "FT_Load_Sfnt_Table");
        bindFunc(cast(void**)&FT_Sfnt_Table_Info, "FT_Sfnt_Table_Info");
        bindFunc(cast(void**)&FT_Get_CMap_Language_ID, "FT_Get_CMap_Language_ID");
        bindFunc(cast(void**)&FT_Get_CMap_Format, "FT_Get_CMap_Format");
        bindFunc(cast(void**)&FT_Get_BDF_Charset_ID, "FT_Get_BDF_Charset_ID");
        bindFunc(cast(void**)&FT_Get_BDF_Property, "FT_Get_BDF_Property");
        bindFunc(cast(void**)&FT_Stream_OpenGzip, "FT_Stream_OpenGzip");
        bindFunc(cast(void**)&FT_Stream_OpenLZW, "FT_Stream_OpenLZW");
        bindFunc(cast(void**)&FT_Get_WinFNT_Header, "FT_Get_WinFNT_Header");
        bindFunc(cast(void**)&FT_Get_Glyph, "FT_Get_Glyph");
        bindFunc(cast(void**)&FT_Glyph_Copy, "FT_Glyph_Copy");
        bindFunc(cast(void**)&FT_Glyph_Transform, "FT_Glyph_Transform");
        bindFunc(cast(void**)&FT_Glyph_Get_CBox, "FT_Glyph_Get_CBox");
        bindFunc(cast(void**)&FT_Glyph_To_Bitmap, "FT_Glyph_To_Bitmap");
        bindFunc(cast(void**)&FT_Done_Glyph, "FT_Done_Glyph");
        bindFunc(cast(void**)&FT_Matrix_Multiply, "FT_Matrix_Multiply");
        bindFunc(cast(void**)&FT_Matrix_Invert, "FT_Matrix_Invert");
        bindFunc(cast(void**)&FT_Bitmap_New, "FT_Bitmap_New");
        bindFunc(cast(void**)&FT_Bitmap_Copy, "FT_Bitmap_Copy");
        bindFunc(cast(void**)&FT_Bitmap_Embolden, "FT_Bitmap_Embolden");
        bindFunc(cast(void**)&FT_Bitmap_Convert, "FT_Bitmap_Convert");
        bindFunc(cast(void**)&FT_Bitmap_Done, "FT_Bitmap_Done");
        bindFunc(cast(void**)&FT_Outline_Get_BBox, "FT_Outline_Get_BBox");
        bindFunc(cast(void**)&FTC_Manager_New, "FTC_Manager_New");
        bindFunc(cast(void**)&FTC_Manager_Reset, "FTC_Manager_Reset");
        bindFunc(cast(void**)&FTC_Manager_Done, "FTC_Manager_Done");
        bindFunc(cast(void**)&FTC_Manager_LookupFace, "FTC_Manager_LookupFace");
        bindFunc(cast(void**)&FTC_Manager_LookupSize, "FTC_Manager_LookupSize");
        bindFunc(cast(void**)&FTC_Node_Unref, "FTC_Node_Unref");
        bindFunc(cast(void**)&FTC_Manager_RemoveFaceID, "FTC_Manager_RemoveFaceID");
        bindFunc(cast(void**)&FTC_CMapCache_New, "FTC_CMapCache_New");
        bindFunc(cast(void**)&FTC_CMapCache_Lookup, "FTC_CMapCache_Lookup");
        bindFunc(cast(void**)&FTC_ImageCache_New, "FTC_ImageCache_New");
        bindFunc(cast(void**)&FTC_ImageCache_Lookup, "FTC_ImageCache_Lookup");
        bindFunc(cast(void**)&FTC_ImageCache_LookupScaler, "FTC_ImageCache_LookupScaler");
        bindFunc(cast(void**)&FTC_SBitCache_New, "FTC_SBitCache_New");
        bindFunc(cast(void**)&FTC_SBitCache_Lookup, "FTC_SBitCache_Lookup");
        bindFunc(cast(void**)&FTC_SBitCache_LookupScaler, "FTC_SBitCache_LookupScaler");
        bindFunc(cast(void**)&FT_Get_Multi_Master, "FT_Get_Multi_Master");
        bindFunc(cast(void**)&FT_Get_MM_Var, "FT_Get_MM_Var");
        bindFunc(cast(void**)&FT_Set_MM_Design_Coordinates, "FT_Set_MM_Design_Coordinates");
        bindFunc(cast(void**)&FT_Set_Var_Design_Coordinates, "FT_Set_Var_Design_Coordinates");
        bindFunc(cast(void**)&FT_Set_MM_Blend_Coordinates, "FT_Set_MM_Blend_Coordinates");
        bindFunc(cast(void**)&FT_Set_Var_Blend_Coordinates, "FT_Set_Var_Blend_Coordinates");
        bindFunc(cast(void**)&FT_Get_Sfnt_Name_Count, "FT_Get_Sfnt_Name_Count");
        bindFunc(cast(void**)&FT_Get_Sfnt_Name, "FT_Get_Sfnt_Name");
        bindFunc(cast(void**)&FT_OpenType_Validate, "FT_OpenType_Validate");
        bindFunc(cast(void**)&FT_OpenType_Free, "FT_OpenType_Free");
        bindFunc(cast(void**)&FT_TrueTypeGX_Validate, "FT_TrueTypeGX_Validate");
        bindFunc(cast(void**)&FT_TrueTypeGX_Free, "FT_TrueTypeGX_Free");
        bindFunc(cast(void**)&FT_ClassicKern_Validate, "FT_ClassicKern_Validate");
        bindFunc(cast(void**)&FT_ClassicKern_Free, "FT_ClassicKern_Free");
        bindFunc(cast(void**)&FT_Get_PFR_Metrics, "FT_Get_PFR_Metrics");
        bindFunc(cast(void**)&FT_Get_PFR_Kerning, "FT_Get_PFR_Kerning");
        bindFunc(cast(void**)&FT_Get_PFR_Advance, "FT_Get_PFR_Advance");
        bindFunc(cast(void**)&FT_Outline_GetInsideBorder, "FT_Outline_GetInsideBorder");
        bindFunc(cast(void**)&FT_Outline_GetOutsideBorder, "FT_Outline_GetOutsideBorder");
        bindFunc(cast(void**)&FT_Stroker_New, "FT_Stroker_New");
        bindFunc(cast(void**)&FT_Stroker_Set, "FT_Stroker_Set");
        bindFunc(cast(void**)&FT_Stroker_Rewind, "FT_Stroker_Rewind");
        bindFunc(cast(void**)&FT_Stroker_ParseOutline, "FT_Stroker_ParseOutline");
        bindFunc(cast(void**)&FT_Stroker_BeginSubPath, "FT_Stroker_BeginSubPath");
        bindFunc(cast(void**)&FT_Stroker_EndSubPath, "FT_Stroker_EndSubPath");
        bindFunc(cast(void**)&FT_Stroker_LineTo, "FT_Stroker_LineTo");
        bindFunc(cast(void**)&FT_Stroker_ConicTo, "FT_Stroker_ConicTo");
        bindFunc(cast(void**)&FT_Stroker_CubicTo, "FT_Stroker_CubicTo");
        bindFunc(cast(void**)&FT_Stroker_GetBorderCounts, "FT_Stroker_GetBorderCounts");
        bindFunc(cast(void**)&FT_Stroker_ExportBorder, "FT_Stroker_ExportBorder");
        bindFunc(cast(void**)&FT_Stroker_GetCounts, "FT_Stroker_GetCounts");
        bindFunc(cast(void**)&FT_Stroker_Export, "FT_Stroker_Export");
        bindFunc(cast(void**)&FT_Stroker_Done, "FT_Stroker_Done");
        bindFunc(cast(void**)&FT_Glyph_Stroke, "FT_Glyph_Stroke");
        bindFunc(cast(void**)&FT_Glyph_StrokeBorder, "FT_Glyph_StrokeBorder");
        bindFunc(cast(void**)&FT_GlyphSlot_Own_Bitmap, "FT_GlyphSlot_Own_Bitmap");
        bindFunc(cast(void**)&FT_GlyphSlot_Embolden, "FT_GlyphSlot_Embolden");
        bindFunc(cast(void**)&FT_GlyphSlot_Oblique, "FT_GlyphSlot_Oblique");
        bindFunc(cast(void**)&FT_Get_X11_Font_Format, "FT_Get_X11_Font_Format");
        bindFunc(cast(void**)&FT_Sin, "FT_Sin");
        bindFunc(cast(void**)&FT_Cos, "FT_Cos");
        bindFunc(cast(void**)&FT_Tan, "FT_Tan");
        bindFunc(cast(void**)&FT_Atan2, "FT_Atan2");
        bindFunc(cast(void**)&FT_Angle_Diff, "FT_Angle_Diff");
        bindFunc(cast(void**)&FT_Vector_Unit, "FT_Vector_Unit");
        bindFunc(cast(void**)&FT_Vector_Rotate, "FT_Vector_Rotate");
        bindFunc(cast(void**)&FT_Vector_Length, "FT_Vector_Length");
        bindFunc(cast(void**)&FT_Vector_Polarize, "FT_Vector_Polarize");
        bindFunc(cast(void**)&FT_Vector_From_Polar, "FT_Vector_From_Polar");
        bindFunc(cast(void**)&FT_Library_SetLcdFilter, "FT_Library_SetLcdFilter");
        bindFunc(cast(void**)&FT_Library_SetLcdFilterWeights, "FT_Library_SetLcdFilterWeights");
        bindFunc(cast(void**)&FT_Get_Gasp, "FT_Get_Gasp");
    }
}

__gshared DerelictFTLoader DerelictFT;

shared static this() {
    DerelictFT = new DerelictFTLoader();
}