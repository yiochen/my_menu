grant execute on function public.api_create_photo_capture(
  uuid,
  uuid,
  text,
  text,
  bigint,
  integer,
  integer,
  text,
  timestamptz
) to authenticated, service_role;

grant execute on function public.api_create_idea_capture(
  uuid,
  uuid,
  text,
  timestamptz
) to authenticated, service_role;

grant execute on function public.api_create_dish_from_capture(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text[],
  text
) to authenticated, service_role;

grant execute on function public.api_discard_capture(
  uuid,
  uuid
) to authenticated, service_role;

notify pgrst, 'reload schema';
