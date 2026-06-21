create policy "authenticated users can read own menu media"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'menu-media'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "authenticated users can upload own menu media"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'menu-media'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "authenticated users can update own menu media"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'menu-media'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
)
with check (
  bucket_id = 'menu-media'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "authenticated users can delete own menu media"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'menu-media'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);
