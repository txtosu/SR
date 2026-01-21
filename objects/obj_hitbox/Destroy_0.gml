// Clean up hit list
if (ds_exists(hitList, ds_type_list))
{
    ds_list_destroy(hitList);
}