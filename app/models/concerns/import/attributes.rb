require 'active_support/concern'

module Concerns
  module Import
    module Attributes
      extend ActiveSupport::Concern

      def attributes_for_person(row)
        attrs = attributes(row).select { |a| a !~ /^family_|^id$/ }
        if @import.create_as_active
          attrs.reverse_merge!(
            'visible_to_everyone'          => true,
            'visible_on_printed_directory' => true,
            'can_sign_in'                  => true,
            'full_access'                  => true
          )
        end
        attrs
      end

      def id_for_person(row)
        attributes(row)['id']
      end

      def attributes_for_family(row)
        family_attributes = attributes(row).select { |a| a =~ /^family_/ }
        family_attributes.each_with_object({}) do |(name, value), hash|
          hash[name.sub(/^family_/, '')] = value unless name == 'family_id'
        end
      end

      def id_for_family(row)
        attributes(row)['family_id']
      end

      def legacy_id_for_family(row)
        attrs = attributes(row)
        attrs['family_legacy_id'] || attrs['legacy_family_id']
      end

      def attributes(row)
        row.import_attributes_as_hash(real_attributes: true)
      end

      def errors_as_string(person)
        family_errors = person.errors.delete(:family)
        errors = person.errors.values
        errors += person.family.errors.values if family_errors
        errors.join('; ')[0...255].presence
      end
    end
  end
end
