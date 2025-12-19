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
    var _current_font = draw_get_font();
    
    var _parsed = cuteify_parse(_string, _asset_prefix);
    var _data = _parsed.data;
    var _string_width = _parsed.widths;
    var _index2 = _parsed.line_count;
    var _index = _parsed.last_index;
    
    var _string_height = ((_current_font == -1) ? 16 : string_height("I")) * _yscale;
    
    var _cos =  dcos(_angle);
    var _sin = -dsin(_angle);
    
    var _angle_90 = _angle - 90;
    
    var _cos_90 =  dcos(_angle_90);
    var _sin_90 = -dsin(_angle_90);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
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
        var _data_len = array_length(_data_current);
        
        for (var j = 0; j < _data_len; ++j)
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
            
            if (j != _data_len - 1) && (_text == CUTEIFY_BRACKET_OPEN) && (_data_current[j + 1][1] != CUTEIFY_TYPE.STRING) continue;
            
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
    
    draw_set_halign(_halign);
    draw_set_valign(_valign);
    
    draw_set_font(_current_font);
}