extend view entity Z07_C_TravelItem with
{
  //base_data_source_name.element_name
  @Consumption.valueHelpDefinition: [
  { entity: { name: '/LRN/437_I_ClassStdVH',
              element: 'ClassID' }
              }
   ]
  Item.ZZclassZ07
}
