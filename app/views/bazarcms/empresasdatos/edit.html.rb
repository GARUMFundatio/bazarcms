<div>

<%= form_for(@empresasdato) do |f| %>

  <% if @empresadato.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@user.errors.count, "error") %> No se ha podido salvar los datos de este periodo:</h2>

      <ul>
      <% @empresasdato.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

<table>
	<tr>
		<td>
    		<%= f.label :Periodo %>
		</td>
		<td colspan="2">
		    <%= f.label @empresasdato.periodo %>			
		</td>
 	</tr>
	<tr>
  	<td>
    	<%= f.label :Empleados %><br />
    </td>
		<td>
			<%= f.select :empleados, options_for_select(Bazarcms::Empresasdato.RangoEmpleados, @empresasdato.empleados) %>
		</td>
	</tr>
	
</table>

 <div class="actions">
    <%= f.submit "Guardar" %>
  </div>
<% end %>

</div>
