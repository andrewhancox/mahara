{foreach from=$form.elements item=element}
    <div class="pseudofieldset collapsible collapsed">
    <span class="pseudolegend"><h4><a href="">{$element.legend}</a></h4></span>
    {foreach from=$element.elements item=item}
        {$item.value|safe}
    {/foreach}
    </div>
{/foreach}
<div class="cl"></div>
<script type="application/javascript">
jQuery(function() {
    jQuery('.pseudofieldset').each(function() {
        var fieldset = jQuery(this);
        var legend = fieldset.find('.pseudolegend').first();
        var legendh4 = legend.find('h4').first();
        legendh4.find('a').click(function(e) {
            fieldset.toggleClass('collapsed');
            var isCollapsed = fieldset.hasClass('collapsed');
            if (!isCollapsed) {
                fieldset.find(':input').not(':hidden').first().focus();
            }
            e.preventDefault();
        });
    });               
});

</script>