global.cuteify_data = {}

/// @func cuteify_parse(_string, _asset_prefix)
/// @desc Parses a cuteify-formatted string into structured data
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Struct}
function cuteify_parse(_string, _asset_prefix = "")
{
    var _cuteify_data = global.cuteify_data;
    
    static _bracket_open_width = undefined;
    static _bracket_close_width = undefined;
    
    if (_bracket_open_width == undefined)
    {
        _bracket_open_width = string_width(CUTEIFY_BRACKET_OPEN);
        _bracket_close_width = string_width(CUTEIFY_BRACKET_CLOSE);
    }
    
    static __data = function(_text, _type = CUTEIFY_TYPE.STRING)
    {
        return [ _text, _type ];
    }
    
    var _string_width = [ 0 ];
    var _data = [[]];
    
    var _index  = 0;
    var _index2 = 0;
    
    var _string_length = string_length(_string);
    var _slice_start = 1;
    var _opened = false;
    
    for (var i = 1; i <= _string_length; ++i)
    {
        var _char = string_char_at(_string, i);
        
        if (_char == CUTEIFY_BRACKET_OPEN)
        {
            var _char_back_is_brace = (i > 1) && ((string_char_at(_string, i - 1) == CUTEIFY_BRACKET_OPEN) || (string_char_at(_string, i - 1) == CUTEIFY_BRACKET_CLOSE));
            var _char_front_is_brace = (i < _string_length) && ((string_char_at(_string, i + 1) == CUTEIFY_BRACKET_OPEN) || (string_char_at(_string, i + 1) == CUTEIFY_BRACKET_CLOSE));
            
            if (i > _slice_start)
            {
                var _part = string_copy(_string, _slice_start, i - _slice_start);
                
                _data[@ _index2][@ _index] = __data(_part);
                _string_width[@ _index2] += string_width(_part);
                
                ++_index;
            }
            
            _slice_start = i + 1;
            
            var _is_text = false;
            
            _data[@ _index2][@ _index] = __data(CUTEIFY_BRACKET_OPEN);
            _string_width[@ _index2] += _bracket_open_width;
            
            ++_index;
            
            continue;
        }
        
        if (_char == "\n")
        {
            if (i > _slice_start)
            {
                var _part = string_copy(_string, _slice_start, i - _slice_start);
                _data[@ _index2][@ _index] = __data(_part);
                _string_width[@ _index2] += string_width(_part);
                ++_index;
            }
            
            _slice_start = i + 1;
            
            _index = 0;
            _string_width[@ ++_index2] = 0;
            _data[@ _index2] = [];
            
            continue;
        }
        
        if (_char == CUTEIFY_BRACKET_CLOSE) && (_index >= 1) && (string_ends_with(_data[_index2][_index - 1][0], CUTEIFY_BRACKET_OPEN))
        {
            var _tag_content = "";
            
            if (i > _slice_start)
            {
                _tag_content = string_copy(_string, _slice_start, i - _slice_start);
            }
            
            _slice_start = i + 1;
            
            if (string_length(_tag_content) > 0)
            {
                var _type = CUTEIFY_TYPE.STRING;
                var _string_colour = hex_parse(_tag_content, false);
                var _processed_content = _tag_content;
                
                if (_string_colour != undefined)
                {
                    _processed_content = _string_colour;
                    _type = CUTEIFY_TYPE.COLOUR;
                }
                else
                {
                    var _emote = undefined;
                    
                    if (_cuteify_data != undefined)
                    {
                        _emote = _cuteify_data[$ $"{_asset_prefix}{_tag_content}"];
                    }
                    else if (variable_global_exists("emote_data"))
                    {
                        _emote = global.emote_data[$ $"{_asset_prefix}{_tag_content}"];
                    }
                    
                    var _asset = asset_get_index($"{_asset_prefix}{_tag_content}");
                    
                     if (_emote != undefined)
                    {
                        _processed_content = _emote;
                        _type = CUTEIFY_TYPE.SPRITE;
                    }
                    else if (font_exists(_asset))
                    {
                        _processed_content = _asset;
                        _type = CUTEIFY_TYPE.FONT;
                    }
                    else if (_tag_content == CUTEIFY_BRACKET_OBSTRUCT)
                    {
                        _processed_content = "";
                        _type = CUTEIFY_TYPE.OBSTRUCT;
                    }
                    else if (_tag_content == CUTEIFY_BRACKET_UNDERLINE)
                    {
                        _processed_content = "";
                        _type = CUTEIFY_TYPE.UNDERLINE;
                    }
                    else
                    {
                        _processed_content = _tag_content + CUTEIFY_BRACKET_CLOSE;
                        _type = CUTEIFY_TYPE.STRING;
                    }
                }
                
                if (_type != CUTEIFY_TYPE.STRING)
                {
                    var _prev_token_str = _data[_index2][_index - 1][CUTEIFY_INDEX.DATA];
                    
                    _data[@ _index2][@ _index - 1][@ CUTEIFY_INDEX.DATA] = string_delete(_prev_token_str, string_length(_prev_token_str), 1);
                }
                
                _data[@ _index2][@ _index] = __data(_processed_content, _type);
                
                if (_type == CUTEIFY_TYPE.SPRITE)
                {
                    _string_width[@ _index2] += sprite_get_width(_processed_content);
                }
                else if (_type == CUTEIFY_TYPE.STRING)
                {
                    _string_width[@ _index2] += string_width(_processed_content);
                }
                
                ++_index;
            }
            else
            {
                _data[@ _index2][@ _index] = __data(CUTEIFY_BRACKET_CLOSE);
                _string_width[@ _index2] += _bracket_close_width;
                
                ++_index;
            }
            
            continue;
        }
    }
    
    if (string_length(_string) >= _slice_start)
    {
        var _part = string_copy(_string, _slice_start, string_length(_string) - _slice_start + 1);
        
        if (string_length(_part) > 0)
        {
             _data[@ _index2][@ _index] = __data(_part);
            _string_width[@ _index2] += string_width(_part);
            
            ++_index;
        }
    }
    
    return {
        data: _data,
        widths: _string_width,
        line_count: _index2,
        last_index: _index
    }
}
