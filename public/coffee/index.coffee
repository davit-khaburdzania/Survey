$ ->
  $("#survey_form").submit (e) ->
    e.preventDefault()
    answers = []
    $(".survey").each (i, el) ->
      answers.push $(el).find("input:checked").val() or null
    where  = $("#survey_form").attr("action")
    
    $.post where, {answers: answers}, (result) ->
      if result?.errors is null
        $("#survey_errors").html("survey submited successfully").attr("class", "success").fadeIn()
      else if result?.errors?
        $("#survey_errors").html(result.errors.join("<br>")).attr("class", "error").fadeIn()
      else
        $("#survey_errors").html("something bad happened").attr("class", "error").fadeIn()

