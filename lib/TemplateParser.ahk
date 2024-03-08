#Requires AutoHotkey v2.0

/**
*Use the specified delimiter to divide the string into an array of substrings. And pad the delimiter back
 *For example: {image}{enter}title:{title}, split by {image} and converted into an array=> ["{image}","{enter}title:{title}"]
 * 
* @param template user template
 * @param identifier delimiter
 */
TemplateConvertedToTemplates(template, identifier){
    if (template == identifier){
      templates := [identifier]
      return templates
    } else {
      templates := StrSplit(template, identifier)
  
      For index, value in templates{
        ; When {image} is at the beginning and end, the item is null, so it (null equals {images}) itself is {images}, and there is no need to supplement {images}
        if (value == ""){
          continue
        }

        ; Correction: When the last item in the template is [normal data]:
        ; The last item does not need to be complemented with {image}, so skip it
        if (index == templates.Length && value != ""){
          continue
        }

        ; Correction: When the last item in the template is {image}:
        ; because It is divided by {image}, so when the last item is {image}, the value is null. When the last item is {image}, its previous item will also be filled with {image}, so the last item is skipped. The previous complement of {image}
        if ((index == templates.Length - 1) && (templates[templates.Length] == "")){
            continue
        }
    
        ; Add {image} after the item that is not {image}. Because it is divided by {image}, the last item of the given array item is all {image}, and {imgae} is added to it.
        if (value != identifier){
          templates.InsertAt(index + 1, identifier)
        }
      }

      ; Correction: When {image} is at the beginning and end, this item is null
      For index, value in templates{
        if (value == "" && index == 1){
            templates[1] := identifier
        }

        if (value == "" && index == templates.Length){
            templates[templates.Length] := identifier
        }
      }

      return templates
    }
}