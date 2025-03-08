enum CUTEIFY_BOOLEAN {
    OBSTRUCT = 1,
    UNDERLINE = 2
}

enum CUTEIFY_INDEX {
    DATA,
    TYPE
}

enum CUTEIFY_TYPE {
    COLOUR,
    SPRITE,
    FONT,
    STRING,
    OBSTRUCT,
    UNDERLINE
}

#macro CUTEIFY_BRACKET_OPEN "{"
#macro CUTEIFY_BRACKET_CLOSE "}"
#macro CUTEIFY_BRACKET_OBSTRUCT "*o"
#macro CUTEIFY_BRACKET_UNDERLINE "*u"

function draw_text_cuteify(_x, _y, _string, _xscale = 1, _yscale = 1, _angle = 0, _colour = c_white, _alpha = 1, _asset_prefix = "")
{
    var _emote_data = global.emote_data;
    
    static __data = function(_text, _type = CUTEIFY_TYPE.STRING)
    {
        return [ _text, _type ];
    }
    
    var _current_font = draw_get_font();
    
    static _string_width = [ 0 ];
    var _string_height = ((_current_font == -1) ? 16 : string_height("I")) * _yscale;
    
    static _data = [[]];
    
    var _index  = 0;
    var _index2 = 0;
    
    var _string_part = "";
    var _string_length = string_length(_string);
    
    var _opened = false;
    
    for (var i = 1; i <= _string_length; ++i)
    {
        var _char = string_char_at(_string, i);
        
        if (_char == CUTEIFY_BRACKET_OPEN)
        {
            var _char_back  = string_char_at(_string, i - 1);
            var _char_front = string_char_at(_string, i + 1);
            
            if (i == _string_length) || ((((_char_back != CUTEIFY_BRACKET_OPEN) || (_char_back != CUTEIFY_BRACKET_CLOSE)) && ((_char_front != CUTEIFY_BRACKET_OPEN) || (_char_front != CUTEIFY_BRACKET_CLOSE))))
            {
                _string_part += CUTEIFY_BRACKET_OPEN;
            }
            
            if (string_length(_string_part) > 0)
            {
                if (array_length(_data) < _index2)
                {
                    _data[@ _index2] = array_create(2);
                }
                
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.DATA] = _string_part;
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.TYPE] = CUTEIFY_TYPE.STRING;
                
                _string_width[@ _index2] += string_width(_string_part);
                
                ++_index;
            }
            else if (i == 1) || (_char_front != CUTEIFY_BRACKET_CLOSE) || ((_char_back == CUTEIFY_BRACKET_OPEN) && (!_opened)) || ((_char_back == CUTEIFY_BRACKET_CLOSE) && (_opened))
            {
                _opened = !_opened;
                
                if (array_length(_data) < _index2)
                {
                    _data[@ _index2] = array_create(2);
                }
                
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.DATA] = CUTEIFY_BRACKET_OPEN;
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.TYPE] = CUTEIFY_TYPE.STRING;
                
                _string_width[@ _index2] += string_width(CUTEIFY_BRACKET_OPEN);
                
                ++_index;
            }
            
            _string_part = "";
            
            continue;
        }
        
        if (_char == "\n")
        {
            if (string_length(_string_part) > 0)
            {
                if (array_length(_data) < _index2)
                {
                    _data[@ _index2] = array_create(2);
                }
                
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.DATA] = _string_part;
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.TYPE] = CUTEIFY_TYPE.STRING;
                
                ++_index;
                
                _string_width[@ _index2] += string_width(_string_part);
            }
            
            _index = 0;
            
            _string_width[@ ++_index2] = 0;
            
            _string_part = "";
            
            continue;
        }
        
        if (_char == CUTEIFY_BRACKET_CLOSE) && (_index >= 1) && (string_ends_with(_data[_index2][_index - 1][0], CUTEIFY_BRACKET_OPEN))
        {
            if (array_length(_data) < _index2)
            {
                _data[@ _index2] = array_create(2);
            }
            
            if (string_length(_string_part) > 0)
            {
                var _type = CUTEIFY_TYPE.STRING;
                
                var _string_colour = hex_parse(_string_part, false);
                
                if (_string_colour != undefined)
                {
                    _string_part = _string_colour;
                    _type = CUTEIFY_TYPE.COLOUR;
                }
                else
                {
                    var _emote = _emote_data[$ $"{_asset_prefix}{_string_part}"];
                    var _asset = asset_get_index($"{_asset_prefix}{_string_part}");
                    
                    if (_emote != undefined)
                    {
                        _string_part = _emote;
                        _type = CUTEIFY_TYPE.SPRITE;
                        
                        _string_width[@ _index2] += sprite_get_width(_emote);
                    }
                    else if (font_exists(_asset))
                    {
                        _string_part = _asset;
                        _type = CUTEIFY_TYPE.FONT;
                    }
                    else if (_string_part == CUTEIFY_BRACKET_OBSTRUCT)
                    {
                        _string_part = "";
                        _type = CUTEIFY_TYPE.OBSTRUCT;
                    }
                    else if (_string_part == CUTEIFY_BRACKET_UNDERLINE)
                    {
                        _string_part = "";
                        _type = CUTEIFY_TYPE.UNDERLINE;
                    }
                    else
                    {
                        _string_part += CUTEIFY_BRACKET_CLOSE;
                        _string_width[@ _index2] += string_width(_string_part);
                    }
                }
                
                if (_index > 0) && (_type != CUTEIFY_TYPE.STRING)
                {
                    var _ = _data[_index2][_index - 1][CUTEIFY_INDEX.DATA];
                    
                    if (string_ends_with(_, CUTEIFY_BRACKET_OPEN))
                    {
                        _data[@ _index2][@ _index - 1][@ CUTEIFY_INDEX.DATA] = string_delete(_, string_length(_), 1);
                    }
                }
                
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.DATA] = _string_part;
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.TYPE] = _type;
            }
            else
            {
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.DATA] = _string_part;
                _data[@ _index2][@ _index][@ CUTEIFY_INDEX.TYPE] = CUTEIFY_TYPE.STRING;
                
                _string_width[@ _index2] += string_width(CUTEIFY_BRACKET_CLOSE);
            }
            
            _string_part = "";
            ++_index;
            
            continue;
        }
        
        _string_part += _char;
    }
    
    if (string_length(_string_part) > 0)
    {
        if (array_length(_data) < _index2)
        {
            _data[@ _index2] = array_create(2);
        }
        
        _data[@ _index2][@ _index][@ CUTEIFY_INDEX.DATA] = _string_part;
        _data[@ _index2][@ _index][@ CUTEIFY_INDEX.TYPE] = CUTEIFY_TYPE.STRING;
        
        ++_index;
        
        _string_width[@ _index2] += string_width(_string_part);
    }
    
    var _cos =  dcos(_angle);
    var _sin = -dsin(_angle);
    
    var _angle_90 = _angle - 90;
    
    var _cos_90 =  dcos(_angle_90);
    var _sin_90 = -dsin(_angle_90);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_left, fa_top);
    
    var _yoffset = 0;
    
    if (_valign == fa_middle)
    {
        _yoffset -= (_string_height * (_index2 + 1)) / 2;
    }
    else if (_valign == fa_bottom)
    {
        _yoffset -= (_string_height * (_index2 + 1));
    }
    
    var _boolean = 0;
    
    for (var i = 0; i <= _index2; ++i)
    {
        var _xoffset = 0;
        
        if (_halign == fa_middle)
        {
            _xoffset -= (_string_width[i] * _xscale) / 2;
        }
        else if (_halign == fa_right)
        {
            _xoffset -= (_string_width[i] * _xscale);
        }
        
        var _data_current = _data[i];
    
        for (var j = 0; j < _index; ++j)
        {
            var _ = _data_current[j];
            
            var _text = _[CUTEIFY_INDEX.DATA];
            var _type = _[CUTEIFY_INDEX.TYPE];
            
            if (_type == CUTEIFY_TYPE.COLOUR)
            {
                _colour = _text;
                
                continue;
            }
            
            if (_type == CUTEIFY_TYPE.SPRITE)
            {
                var _x2 = (sprite_get_xoffset(_text) * _xscale) + _xoffset;
                var _y2 = (sprite_get_yoffset(_text) * _yscale) + _yoffset + (sprite_get_height(_text) * _yscale / 2);
                
                draw_sprite_ext(
                    _text,
                    0,
                    _x + (_y2 * _cos_90) + (_x2 * _cos),
                    _y + (_y2 * _sin_90) + (_x2 * _sin),
                    _xscale,
                    _yscale,
                    _angle,
                    _colour,
                    _alpha
                );
                
                _xoffset += sprite_get_width(_text) * _xscale;
                
                continue;
            }
            
            if (_type == CUTEIFY_TYPE.FONT)
            {
                draw_set_font(_text);
                
                _string_height = string_height("I") * _yscale;
                
                continue;
            }
            
            if (j != _index - 1) && (_text == CUTEIFY_BRACKET_OPEN) && (_data_current[j + 1][1] != CUTEIFY_TYPE.STRING) continue;
            
            if (_type == CUTEIFY_TYPE.OBSTRUCT)
            {
                _boolean ^= CUTEIFY_BOOLEAN.OBSTRUCT;
                
                continue;
            }
            
            if (_type == CUTEIFY_TYPE.UNDERLINE)
            {
                _boolean ^= CUTEIFY_BOOLEAN.UNDERLINE;
                
                continue;
            }
            
            var _text_length = string_length(_text);
            
            if (_text_length <= 0) continue;
            
            var _xoffset_cos = _xoffset * _cos;
            var _xoffset_sin = _xoffset * _sin;
            
            if (_boolean & CUTEIFY_BOOLEAN.OBSTRUCT)
            {
                var _xstart = _x + (_yoffset * _cos_90);
                var _ystart = _y + (_yoffset * _sin_90);
                
                for (var l = 1; l <= _text_length; ++l)
                {
                    if (string_char_at(_text, l) == " ")
                    {
                        draw_text_transformed_color(
                            _xstart + (_xoffset * _cos),
                            _ystart + (_xoffset * _sin),
                            " ",
                            _xscale,
                            _yscale,
                            _angle,
                            _colour,
                            _colour,
                            _colour,
                            _colour,
                            _alpha
                        );
                        
                        _xoffset += string_width(" ") * _xscale;
                        
                        continue;
                    }
                    
                    var _char_random = chr(irandom_range(32, 127));
                    
                    draw_text_transformed_color(
                        _xstart + (_xoffset * _cos),
                        _ystart + (_xoffset * _sin),
                        _char_random,
                        _xscale,
                        _yscale,
                        _angle,
                        _colour,
                        _colour,
                        _colour,
                        _colour,
                        _alpha
                    );
                    
                    _xoffset += string_width(_char_random) * _xscale;
                }
            }
            else
            {
                draw_text_transformed_color(
                    _x + (_yoffset * _cos_90) + _xoffset_cos,
                    _y + (_yoffset * _sin_90) + _xoffset_sin,
                    _text,
                    _xscale,
                    _yscale,
                    _angle,
                    _colour,
                    _colour,
                    _colour,
                    _colour,
                    _alpha
                );
                
                _xoffset += string_width(_text) * _xscale;
            }
            
            if (_boolean & CUTEIFY_BOOLEAN.UNDERLINE)
            {
                var _yoffset2_cos = _x + ((_yoffset + _string_height) * _cos_90);
                var _yoffset2_sin = _y + ((_yoffset + _string_height) * _sin_90);
                
                draw_line_colour(
                    _yoffset2_cos + _xoffset_cos,
                    _yoffset2_sin + _xoffset_sin,
                    _yoffset2_cos + (_xoffset * _cos),
                    _yoffset2_sin + (_xoffset * _sin),
                    _colour,
                    _colour
                );
            }
        }
        
        _yoffset += _string_height;
    }
    
    draw_set_align(_halign, _valign);
    draw_set_font(_current_font);
    
    _string_width[0] = 0;
}