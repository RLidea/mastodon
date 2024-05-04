# frozen_string_literal: true

module Account::Avatar
  extend ActiveSupport::Concern

  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].freeze
  LIMIT = 4.megabytes

  class_methods do
    def avatar_styles(file)
      styles = { original: { geometry: '400x400#', file_geometry_parser: FastGeometryParser } }
      styles[:original][:format] = 'webp' if file.content_type != 'image/gif'
      styles[:static] = { geometry: '400x400#', format: 'webp', convert_options: '-coalesce', file_geometry_parser: FastGeometryParser } if file.content_type == 'image/gif'
      styles
    end

    private :avatar_styles
  end

  included do
    # Avatar upload
    has_attached_file :avatar, styles: ->(f) { avatar_styles(f) }, convert_options: { all: '+profile "!icc,*" +set date:modify +set date:create +set date:timestamp' }, processors: [:lazy_thumbnail, :type_corrector]
    validates_attachment_content_type :avatar, content_type: IMAGE_MIME_TYPES
    validates_attachment_size :avatar, less_than: LIMIT
    remotable_attachment :avatar, LIMIT, suppress_errors: false
  end

  def avatar_original_url
    avatar_file_name.nil? && domain.nil? ? '/avatars/original/missing_qdon.png' : avatar.url(:original)
  end

  def avatar_static_url
    avatar_content_type == 'image/gif' ? avatar.url(:static) : avatar_original_url
  end
end