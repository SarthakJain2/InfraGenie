using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

namespace Rhipheus.Genie.Core;

public class ExpandoObjectConverter : JsonConverter<ExpandoObject>
{

    public static string ToPascalCase(string input)
    {
        if (string.IsNullOrEmpty(input))
        {
            return input;
        }

        string pascalCase = Regex.Replace(input, "(\\B[A-Z])", " $1");
        TextInfo textInfo = CultureInfo.CurrentCulture.TextInfo;

        return textInfo.ToTitleCase(pascalCase).Replace(" ", "");
    }

    public override ExpandoObject Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType != JsonTokenType.StartObject)
        {
            throw new JsonException();
        }

        var expandoObject = new ExpandoObject();
        var dictionary = (IDictionary<string, object>)expandoObject;

        while (reader.Read())
        {
            if (reader.TokenType == JsonTokenType.EndObject)
            {
                return expandoObject;
            }

            if (reader.TokenType == JsonTokenType.PropertyName)
            {
                var propertyName = ToPascalCase(reader.GetString());
                reader.Read();
                var value = DeserializeValue(ref reader);
                dictionary[propertyName] = value;
            }
        }

        throw new JsonException();
    }

    private object DeserializeValue(ref Utf8JsonReader reader)
    {
        switch (reader.TokenType)
        {
            case JsonTokenType.True:
                return true;
            case JsonTokenType.False:
                return false;
            case JsonTokenType.Number:
                if (reader.TryGetInt32(out int intValue))
                {
                    return intValue;
                }
                return reader.GetDouble();
            case JsonTokenType.String:
                return reader.GetString();
            case JsonTokenType.Null:
                return null;
            case JsonTokenType.StartArray:
                var list = new List<object>();
                while (reader.Read())
                {
                    if (reader.TokenType == JsonTokenType.EndArray)
                    {
                        return list;
                    }
                    list.Add(DeserializeValue(ref reader));
                }
                throw new JsonException();
            case JsonTokenType.StartObject:
                return Read(ref reader, typeof(ExpandoObject), null);
            default:
                throw new JsonException();
        }
    }

    public override void Write(Utf8JsonWriter writer, ExpandoObject value, JsonSerializerOptions options)
    {
        writer.WriteStartObject();

        foreach (var kvp in (IDictionary<string, object>)value)
        {
            writer.WritePropertyName(JsonNamingPolicy.CamelCase.ConvertName(kvp.Key));
            JsonSerializer.Serialize(writer, kvp.Value, options);
        }

        writer.WriteEndObject();
    }
}
