$ ->
  $("#survey_form").submit (e) ->
    e.preventDefault()
    answer = $(this).serializeArray()[0].value
    where  = $("#survey_form").attr("action")
    $.post where, {answer}, (result) ->
      if result?.errors is null
        $("#survey_errors").html("survey submited successfully").attr("class", "success").fadeIn()
      else if result?.errors?
        $("#survey_errors").html(result.errors.join("<br>")).attr("class", "error").fadeIn()
      else
        $("#survey_errors").html("something bad happened").attr("class", "error").fadeIn()

