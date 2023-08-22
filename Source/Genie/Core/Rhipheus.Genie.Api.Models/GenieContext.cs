using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace Rhipheus.Genie.Api.Models;

public partial class GenieContext : DbContext
{
    private readonly IConfiguration _configuration;
    
    public GenieContext(DbContextOptions<GenieContext> options, IConfiguration configuration)
        : base(options)
    {
        _configuration = configuration;
    }

    public virtual DbSet<ChatMessage> ChatMessages { get; set; }

    public virtual DbSet<ChatThread> ChatThreads { get; set; }

    public virtual DbSet<Document> Documents { get; set; }

    public virtual DbSet<Tenant> Tenants { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer(
                _configuration.GetConnectionString("DefaultConnection"),
                options => options.EnableRetryOnFailure()
            );
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ChatMessage>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ChatMess__3214EC07C6400055");

            entity.ToTable("ChatMessage");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.DateCreated).HasColumnType("datetime");

            entity.HasOne(d => d.Document).WithMany(p => p.ChatMessages)
                .HasForeignKey(d => d.DocumentId)
                .HasConstraintName("FK_ChatMessage_Document");

            entity.HasOne(d => d.Thread).WithMany(p => p.ChatMessages)
                .HasForeignKey(d => d.ThreadId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ChatMessage_ChatThread_ID");
        });

        modelBuilder.Entity<ChatThread>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ChatThre__3214EC07686A0F61");

            entity.ToTable("ChatThread");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.DateCreated).HasColumnType("datetime");
            entity.Property(e => e.Name).HasMaxLength(250);
        });

        modelBuilder.Entity<Document>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Document__3214EC07B82C4BF6");

            entity.ToTable("Document");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.LinkType)
                .HasMaxLength(15)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Tenant>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Tenant__3214EC07EDD1BD4D");

            entity.ToTable("Tenant");

            entity.Property(e => e.Id).ValueGeneratedNever();
        });

        OnModelCreatingPartial(modelBuilder);
       
}
   


    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
